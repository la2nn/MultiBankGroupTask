//
//  MockWebSocketService.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import Combine
@testable import MultiBankGroupTask

final class MockWebSocketService: WebSocketServiceProtocol, @unchecked Sendable {

    let stockPriceSubject = PassthroughSubject<StockPriceMessage, Never>()
    let connectionStateSubject = CurrentValueSubject<ServiceConnectionState, Never>(.disconnected)

    private(set) var connectCallCount = 0
    private(set) var disconnectCallCount = 0
    private(set) var sentMessages: [StockPriceMessage] = []

    var onConnect: (() -> Void)?
    var onDisconnect: (() -> Void)?

    var stockPricePublisher: AnyPublisher<StockPriceMessage, Never> {
        stockPriceSubject.eraseToAnyPublisher()
    }

    var connectionStatePublisher: AnyPublisher<ServiceConnectionState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }

    func connect() async {
        connectCallCount += 1
        onConnect?()
    }

    func disconnect() async {
        disconnectCallCount += 1
        onDisconnect?()
    }

    func send(_ message: StockPriceMessage) async {
        sentMessages.append(message)
    }
}
