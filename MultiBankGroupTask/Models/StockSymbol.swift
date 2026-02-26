//
//  StockSymbol.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import Foundation

struct StockSymbol: Identifiable, Equatable {
    enum PriceDirection {
        case up
        case down
        case none
    }

    let id: String
    let companyName: String
    let companyDescription: String

    private(set) var currentPrice: Decimal
    private(set) var previousPrice: Decimal

    mutating func applyPriceUpdate(_ message: StockPriceMessage) {
        previousPrice = currentPrice
        currentPrice = message.price
    }

    var priceDirection: PriceDirection {
        if currentPrice > previousPrice {
            return .up
        } else if currentPrice < previousPrice {
            return .down
        }
        return .none
    }
}
