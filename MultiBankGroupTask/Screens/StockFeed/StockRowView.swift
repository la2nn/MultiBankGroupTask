//
//  StockRowView.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import SwiftUI

struct StockRowView: View {
    let symbol: StockSymbol

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(symbol.id)
                    .font(.headline)
                Text(symbol.companyName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .lineLimit(1)
            .frame(minWidth: 80, alignment: .leading)

            Spacer()

            HStack(spacing: 4) {
                Text(symbol.formattedPrice)
                    .font(.body.monospacedDigit())
                    .foregroundStyle(symbol.priceColor)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: symbol.formattedPrice)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Text(symbol.directionArrow)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(symbol.priceIndicatorColor)
                    .contentTransition(.interpolate)
                    .animation(.easeInOut(duration: 0.4), value: symbol.priceDirection)
                    .frame(width: 16)
            }
        }
        .padding(.vertical, 4)
    }
}
