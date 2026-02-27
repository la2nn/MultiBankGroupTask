//
//  StockSymbolTests.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import XCTest
@testable import MultiBankGroupTask

final class StockSymbolTests: XCTestCase {

    // MARK: - Initial State

    func test_initialState_previousPriceEqualsCurrentPrice() {
        let symbol = makeSymbol(price: 100)

        XCTAssertEqual(symbol.currentPrice, 100)
        XCTAssertEqual(symbol.previousPrice, 100)
        XCTAssertEqual(symbol.priceDirection, .none)
    }

    // MARK: - Price Update Direction

    func test_applyPriceUpdate_priceGoesUp_directionIsUp() {
        var symbol = makeSymbol(price: 100)

        symbol.applyPriceUpdate(110)

        XCTAssertEqual(symbol.priceDirection, .up)
        XCTAssertEqual(symbol.currentPrice, 110)
        XCTAssertEqual(symbol.previousPrice, 100)
    }

    func test_applyPriceUpdate_priceGoesDown_directionIsDown() {
        var symbol = makeSymbol(price: 100)

        symbol.applyPriceUpdate(90)

        XCTAssertEqual(symbol.priceDirection, .down)
        XCTAssertEqual(symbol.currentPrice, 90)
        XCTAssertEqual(symbol.previousPrice, 100)
    }

    func test_applyPriceUpdate_priceSame_directionIsNone() {
        var symbol = makeSymbol(price: 100)

        symbol.applyPriceUpdate(100)

        XCTAssertEqual(symbol.priceDirection, .none)
    }

    // MARK: - Formatted Price

    func test_formattedPrice_USDFormat() {
        let symbol = makeSymbol(price: 178.72)

        XCTAssertTrue(symbol.formattedPrice.contains("178.72"))
    }

    func test_formattedPrice_updatedAfterPriceChange() {
        var symbol = makeSymbol(price: 100)

        symbol.applyPriceUpdate(250.99)

        XCTAssertTrue(symbol.formattedPrice.contains("250.99"))
    }
}

// MARK: - Helpers

private extension StockSymbolTests {
    func makeSymbol(price: Decimal) -> StockSymbol {
        StockSymbol(
            id: "TEST",
            companyName: "Test Inc.",
            companyDescription: "A test company.",
            currentPrice: price
        )
    }
}
