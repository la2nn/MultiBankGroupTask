//
//  StockPriceGenerator.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import Foundation

protocol StockPriceGeneratorProtocol {
    func startEmitting(to service: WebSocketServiceProtocol) async
    func stopEmitting() async
}

actor StockPriceGenerator: StockPriceGeneratorProtocol {

    private var timerTask: Task<Void, Never>?
    private var prices: [String: Decimal]
    private let interval: Duration

    init(tickers: [StockSymbol], interval: Duration = .seconds(2)) {
        self.prices = Dictionary(
            uniqueKeysWithValues: tickers.map { ($0.id, $0.currentPrice) }
        )
        self.interval = interval
    }

    func startEmitting(to service: WebSocketServiceProtocol) async {
        guard timerTask == nil else { return }
        timerTask = Task {
            while !Task.isCancelled {
                for (symbol, currentPrice) in prices {
                    let newPrice = generateRandomPrice(from: currentPrice)
                    prices[symbol] = newPrice
                    let message = StockPriceMessage(symbol: symbol, price: newPrice)
                    await service.send(message)
                }
                try? await Task.sleep(for: interval)
            }
        }
    }

    func stopEmitting() {
        timerTask?.cancel()
        timerTask = nil
    }
}

// MARK: - Private

private extension StockPriceGenerator {
    func generateRandomPrice(
        from currentPrice: Decimal,
        percentRange: ClosedRange<Double> = -0.05...0.05
    ) -> Decimal {
        currentPrice + currentPrice * Decimal(Double.random(in: percentRange))
    }
}
