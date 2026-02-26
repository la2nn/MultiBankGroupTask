//
//  StockPriceMessage.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import Foundation

struct StockPriceMessage: Codable {
    let symbol: String
    let price: Decimal
}
