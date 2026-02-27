//
//  StockFeedViewModelTests.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import Combine
import XCTest
@testable import MultiBankGroupTask

@MainActor
final class StockFeedViewModelTests: XCTestCase {

    private var sut: StockFeedViewModel!
    private var mockService: MockWebSocketService!
    private var mockGenerator: MockStockPriceGenerator!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() async throws {
        mockService = MockWebSocketService()
        mockGenerator = MockStockPriceGenerator()
        sut = StockFeedViewModel(
            tickers: [
                StockSymbol(id: "AAA", companyName: "A Co.", companyDescription: "", currentPrice: 300),
                StockSymbol(id: "BBB", companyName: "B Co.", companyDescription: "", currentPrice: 200),
                StockSymbol(id: "CCC", companyName: "C Co.", companyDescription: "", currentPrice: 100),
            ],
            webSocketService: mockService,
            priceGenerator: mockGenerator
        )
        cancellables = []
        try await super.setUp()
    }

    override func tearDown() async throws {
        sut = nil
        mockService = nil
        mockGenerator = nil
        cancellables = nil
        try await super.tearDown()
    }

    // MARK: - Start / Stop

    func test_start_setsFeedStateToConnecting() {
        sut.start()
        XCTAssertEqual(sut.feedState, .connecting)
    }

    func test_start_callsConnect() async {
        let exp = expectation(description: "connect called")
        mockService.onConnect = { exp.fulfill() }

        sut.start()
        await fulfillment(of: [exp], timeout: 1)

        XCTAssertEqual(mockService.connectCallCount, 1)
    }

    func test_stop_callsDisconnect() async {
        let exp = expectation(description: "disconnect called")
        mockService.onDisconnect = { exp.fulfill() }

        sut.stop()
        await fulfillment(of: [exp], timeout: 1)

        XCTAssertEqual(mockService.disconnectCallCount, 1)
    }

    // MARK: - Connection State

    func test_connectionStateConnected_setsFeedState() async {
        let exp = expectation(description: "feedState connected")

        sut.$feedState
            .dropFirst()
            .filter { $0 == .connected }
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)

        mockService.connectionStateSubject.send(.connected)
        await fulfillment(of: [exp], timeout: 1)

        XCTAssertEqual(sut.feedState, .connected)
    }

    func test_connectionStateConnected_startsGenerator() async {
        let exp = expectation(description: "startEmitting called")
        mockGenerator.onStartEmitting = { exp.fulfill() }

        mockService.connectionStateSubject.send(.connected)
        await fulfillment(of: [exp], timeout: 1)

        XCTAssertEqual(mockGenerator.startEmittingCallCount, 1)
    }

    func test_connectionStateDisconnected_setsFeedState() async {
        let connectedExp = expectation(description: "connected")
        sut.$feedState
            .dropFirst()
            .filter { $0 == .connected }
            .sink { _ in connectedExp.fulfill() }
            .store(in: &cancellables)

        mockService.connectionStateSubject.send(.connected)
        await fulfillment(of: [connectedExp], timeout: 1)

        let disconnectedExp = expectation(description: "disconnected")
        sut.$feedState
            .dropFirst()
            .filter { $0 == .disconnected }
            .sink { _ in disconnectedExp.fulfill() }
            .store(in: &cancellables)

        mockService.connectionStateSubject.send(.disconnected)
        await fulfillment(of: [disconnectedExp], timeout: 1)

        XCTAssertEqual(sut.feedState, .disconnected)
    }

    func test_connectionStateDisconnected_stopsGenerator() async {
        let startExp = expectation(description: "startEmitting called")
        mockGenerator.onStartEmitting = { startExp.fulfill() }

        mockService.connectionStateSubject.send(.connected)
        await fulfillment(of: [startExp], timeout: 1)

        let countBeforeDisconnect = mockGenerator.stopEmittingCallCount

        let stopExp = expectation(description: "stopEmitting called")
        mockGenerator.onStopEmitting = { stopExp.fulfill() }

        mockService.connectionStateSubject.send(.disconnected)
        await fulfillment(of: [stopExp], timeout: 1)

        XCTAssertEqual(mockGenerator.stopEmittingCallCount, countBeforeDisconnect + 1)
    }

    // MARK: - Price Updates

    func test_priceUpdate_updatesDictionary() async {
        let exp = expectation(description: "dictionary updated")

        sut.$tickersDictionary
            .dropFirst()
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)

        mockService.stockPriceSubject.send(StockPriceMessage(symbol: "CCC", price: 500))
        await fulfillment(of: [exp], timeout: 1)

        XCTAssertEqual(sut.tickersDictionary["CCC"]?.currentPrice, 500)
    }

    func test_priceUpdate_reordersSortedTickers() async {
        let exp = expectation(description: "tickers reordered")

        sut.$sortedTickers
            .dropFirst()
            .filter { $0.first == "CCC" }
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)

        // CCC (100) → 500, should become first
        mockService.stockPriceSubject.send(StockPriceMessage(symbol: "CCC", price: 500))
        await fulfillment(of: [exp], timeout: 1)

        XCTAssertEqual(sut.sortedTickers, ["CCC", "AAA", "BBB"])
    }

    func test_priceUpdate_unknownTicker_ignored() async {
        let exp = expectation(description: "should not update")
        exp.isInverted = true

        sut.$sortedTickers
            .dropFirst()
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)

        mockService.stockPriceSubject.send(StockPriceMessage(symbol: "UNKNOWN", price: 999))
        await fulfillment(of: [exp], timeout: 0.5)

        XCTAssertEqual(sut.sortedTickers, ["AAA", "BBB", "CCC"])
        XCTAssertNil(sut.tickersDictionary["UNKNOWN"])
    }

    func test_priceUpdate_samePosition_noReorder() async {
        let exp = expectation(description: "dictionary updated")

        sut.$tickersDictionary
            .dropFirst()
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)

        // AAA (300) → 299, still highest
        mockService.stockPriceSubject.send(StockPriceMessage(symbol: "AAA", price: 299))
        await fulfillment(of: [exp], timeout: 1)

        XCTAssertEqual(sut.sortedTickers, ["AAA", "BBB", "CCC"])
        XCTAssertEqual(sut.tickersDictionary["AAA"]?.currentPrice, 299)
    }
}
