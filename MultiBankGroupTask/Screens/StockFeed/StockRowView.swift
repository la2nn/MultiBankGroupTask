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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(symbol.id)
                    .font(.headline)
                Text(symbol.companyName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Text("\(symbol.currentPrice)")
                    .font(.body.monospacedDigit())
                priceDirectionView
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Subviews

private extension StockRowView {
    @ViewBuilder
    var priceDirectionView: some View {
        switch symbol.priceDirection {
        case .up:
            Image(systemName: "arrow.up")
                .foregroundStyle(.green)
                .font(.caption)
        case .down:
            Image(systemName: "arrow.down")
                .foregroundStyle(.red)
                .font(.caption)
        case .none:
            Image(systemName: "minus")
                .foregroundStyle(.gray)
                .font(.caption)
        }
    }
}
