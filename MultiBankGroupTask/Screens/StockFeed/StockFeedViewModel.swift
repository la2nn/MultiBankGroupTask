//
//  StockFeedViewModel.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import Combine
import Foundation

@MainActor
final class StockFeedViewModel: ObservableObject {
    enum FeedState {
        case disconnected
        case connecting
        case connected
    }

    @Published private(set) var feedState: FeedState
    @Published private(set) var sortedTickers: [String]
    @Published private(set) var tickersDictionary: [String: StockSymbol]

    private var tickerIndexMap: [String: Int]

    private let webSocketService: WebSocketServiceProtocol
    private let priceGenerator: StockPriceGeneratorProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        tickers: [StockSymbol],
        webSocketService: WebSocketServiceProtocol,
        priceGenerator: StockPriceGeneratorProtocol
    ) {
        self.webSocketService = webSocketService
        self.priceGenerator = priceGenerator
        self.feedState = .disconnected

        let sortedByPrice = tickers.sorted { $0.currentPrice > $1.currentPrice }

        self.tickersDictionary = Dictionary(uniqueKeysWithValues: tickers.map { ($0.id, $0) })
        self.sortedTickers = sortedByPrice.map(\.id)
        self.tickerIndexMap = Dictionary(uniqueKeysWithValues: sortedByPrice.enumerated().map { ($1.id, $0) })

        bindWebSocket()
    }

    func start() {
        startFeed()
    }

    func stop() {
        stopFeed()
    }
}

// MARK: - Private

private extension StockFeedViewModel {
    func bindWebSocket() {
        webSocketService.connectionStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleConnectionStateChange(state)
            }
            .store(in: &cancellables)

        webSocketService.stockPricePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.handlePriceUpdate(message)
            }
            .store(in: &cancellables)
    }

    func handleConnectionStateChange(_ state: ServiceConnectionState) {
        switch state {
        case .connected:
            feedState = .connected
            Task {
                await priceGenerator.startEmitting(to: webSocketService)
            }
        case .disconnected:
            feedState = .disconnected
            Task {
                await priceGenerator.stopEmitting()
            }
        }
    }

    func startFeed() {
        feedState = .connecting
        Task {
            await webSocketService.connect()
        }
    }

    func stopFeed() {
        Task {
            await webSocketService.disconnect()
        }
    }

    func handlePriceUpdate(_ message: StockPriceMessage) {
        let ticker = message.symbol

        guard var symbol = tickersDictionary[ticker], let oldIndex = tickerIndexMap[ticker] else {
            return
        }

        // O(1) — update price in dictionary
        symbol.applyPriceUpdate(message)
        tickersDictionary[ticker] = symbol

        let newPrice = symbol.currentPrice

        // O(log n) — binary search for new position
        let newIndex = findInsertionIndex(for: newPrice, excluding: oldIndex)

        guard oldIndex != newIndex else { return }

        // O(k) — move ticker in sorted array
        sortedTickers.remove(at: oldIndex)
        let insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex
        sortedTickers.insert(ticker, at: insertAt)

        // O(k) — update index map for affected range
        let rangeStart = min(oldIndex, insertAt)
        let rangeEnd = max(oldIndex, insertAt)
        for i in rangeStart...rangeEnd {
            tickerIndexMap[sortedTickers[i]] = i
        }
    }

    // binary search
    func findInsertionIndex(for price: Decimal, excluding oldIndex: Int) -> Int {
        var low = 0
        var high = sortedTickers.count

        while low < high {
            let mid = (low + high) / 2
            let midTicker = sortedTickers[mid]

            // Skip the element being moved
            if mid == oldIndex {
                let midPrice = tickersDictionary[midTicker]?.previousPrice ?? 0
                if price > midPrice {
                    high = mid
                } else {
                    low = mid + 1
                }
                continue
            }

            let midPrice = tickersDictionary[midTicker]?.currentPrice ?? 0
            if price > midPrice {
                high = mid
            } else {
                low = mid + 1
            }
        }

        return low
    }
}
