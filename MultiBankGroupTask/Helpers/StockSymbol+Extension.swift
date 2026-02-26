//
//  StockSymbol+Extension.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import SwiftUI

extension StockSymbol {
    var directionArrow: String {
        switch priceDirection {
        case .up: "↑"
        case .down: "↓"
        case .none: "–"
        }
    }

    var priceColor: Color {
        switch priceDirection {
        case .up: .green
        case .down: .red
        case .none: .primary
        }
    }

    var priceIndicatorColor: Color {
        switch priceDirection {
        case .up: .green
        case .down: .red
        case .none: .gray
        }
    }
}
