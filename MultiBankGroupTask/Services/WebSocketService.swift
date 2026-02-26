//
//  WebSocketService.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import Foundation
import Combine

nonisolated protocol WebSocketServiceProtocol: Sendable {
    var stockPricePublisher: AnyPublisher<StockPriceMessage, Never> { get }
    var connectionStatePublisher: AnyPublisher<ServiceConnectionState, Never> { get }

    func connect() async
    func disconnect() async
    func send(_ message: StockPriceMessage) async
}

actor WebSocketService: WebSocketServiceProtocol {

    private nonisolated static let stockPriceUrl = "wss://ws.postman-echo.com/raw"

    nonisolated(unsafe) private let stockPriceSubject = PassthroughSubject<StockPriceMessage, Never>()
    nonisolated(unsafe) private let connectionStateSubject = CurrentValueSubject<ServiceConnectionState, Never>(.disconnected)

    private var webSocketTask: URLSessionWebSocketTask?
    private var listeningTask: Task<Void, Never>?
    private let session: URLSession
    private let delegate: WebSocketDelegate
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    // MARK: Publishers

    nonisolated var stockPricePublisher: AnyPublisher<StockPriceMessage, Never> {
        stockPriceSubject.eraseToAnyPublisher()
    }

    nonisolated var connectionStatePublisher: AnyPublisher<ServiceConnectionState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }

    // MARK: Init

    init() {
        let delegate = WebSocketDelegate()
        self.delegate = delegate
        self.session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)

        delegate.onOpen = { [weak self] in
            self?.connectionStateSubject.send(.connected)
        }
        delegate.onClose = { [weak self] in
            self?.connectionStateSubject.send(.disconnected)
        }
    }

    // MARK: Internal Methods

    func connect() {
        guard let url = URL(string: WebSocketService.stockPriceUrl) else { return }
        let task = session.webSocketTask(with: url)
        webSocketTask = task
        startListening()
        task.resume()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        handleDisconnection()
    }

    func send(_ message: StockPriceMessage) async {
        guard let webSocketTask,
              let data = try? encoder.encode(message),
              let jsonString = String(data: data, encoding: .utf8)
        else {
            return
        }

        do {
            try await webSocketTask.send(.string(jsonString))
        } catch {
            handleDisconnection()
        }
    }
}

// MARK: - Private

private extension WebSocketService {
    func startListening() {
        guard let webSocketTask else { return }

        listeningTask = Task {
            while !Task.isCancelled {
                do {
                    let message = try await webSocketTask.receive()
                    handleMessage(message)
                } catch {
                    handleDisconnection()
                    break
                }
            }
        }
    }

    func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        let data: Data?

        switch message {
        case let .string(text):
            data = text.data(using: .utf8)
        case let .data(messageData):
            data = messageData
        @unknown default:
            data = nil
        }

        guard let data, let priceMessage = try? decoder.decode(StockPriceMessage.self, from: data) else {
            return
        }

        stockPriceSubject.send(priceMessage)
    }

    func handleDisconnection() {
        listeningTask?.cancel()
        listeningTask = nil
        webSocketTask = nil
    }
}

// MARK: - WebSocketDelegate

private extension WebSocketService {
    final class WebSocketDelegate: NSObject, URLSessionWebSocketDelegate, @unchecked Sendable {
        var onOpen: (() -> Void)?
        var onClose: (() -> Void)?

        func urlSession(
            _ session: URLSession,
            webSocketTask: URLSessionWebSocketTask,
            didOpenWithProtocol protocol: String?
        ) {
            onOpen?()
        }

        func urlSession(
            _ session: URLSession,
            webSocketTask: URLSessionWebSocketTask,
            didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
            reason: Data?
        ) {
            onClose?()
        }
    }
}
