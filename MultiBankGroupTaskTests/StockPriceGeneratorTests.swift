//
//  StockPriceGeneratorTests.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import XCTest
@testable import MultiBankGroupTask

final class StockPriceGeneratorTests: XCTestCase {

    func test_generatedPrices_withinFivePercentRange() async {
        let initialPrice: Decimal = 100
        let tickers = [
            StockSymbol(id: "TEST", companyName: "Test", companyDescription: "", currentPrice: initialPrice)
        ]
        let sut = await StockPriceGenerator(tickers: tickers, interval: .milliseconds(20))
        let mockService = MockWebSocketService()

        await sut.startEmitting(to: mockService)
        try? await Task.sleep(for: .milliseconds(50))
        await sut.stopEmitting()

        XCTAssertFalse(mockService.sentMessages.isEmpty)

        var previousPrice = initialPrice
        for message in mockService.sentMessages {
            let lowerBound = previousPrice * Decimal(string: "0.95")!
            let upperBound = previousPrice * Decimal(string: "1.05")!

            XCTAssertGreaterThanOrEqual(message.price, lowerBound,
                "Price \(message.price) below 5% range of \(previousPrice)")
            XCTAssertLessThanOrEqual(message.price, upperBound,
                "Price \(message.price) above 5% range of \(previousPrice)")

            previousPrice = message.price
        }
    }

    func test_stopEmitting_stopsGeneration() async {
        let tickers = [
            StockSymbol(id: "TEST", companyName: "Test", companyDescription: "", currentPrice: 100)
        ]
        let sut = await StockPriceGenerator(tickers: tickers, interval: .milliseconds(20))
        let mockService = MockWebSocketService()

        await sut.startEmitting(to: mockService)
        try? await Task.sleep(for: .milliseconds(50))
        await sut.stopEmitting()

        let countAfterStop = mockService.sentMessages.count
        try? await Task.sleep(for: .milliseconds(50))

        XCTAssertEqual(mockService.sentMessages.count, countAfterStop)
    }
}
