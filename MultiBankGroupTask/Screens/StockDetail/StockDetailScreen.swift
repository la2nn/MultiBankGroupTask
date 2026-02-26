//
//  StockDetailScreen.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import SwiftUI

struct StockDetailScreen: View {
    @ObservedObject var viewModel: StockFeedViewModel

    let ticker: String

    private var symbol: StockSymbol? {
        viewModel.tickersDictionary[ticker]
    }

    var body: some View {
        Group {
            if let symbol {
                List {
                    priceSection(symbol)
                    descriptionSection(symbol)
                }
                .listStyle(.insetGrouped)
                .navigationTitle(symbol.id)
            }
        }
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Sections

private extension StockDetailScreen {
    func priceSection(_ symbol: StockSymbol) -> some View {
        Section {
            HStack {
                Text(symbol.formattedPrice)
                    .font(.largeTitle.monospacedDigit().bold())
                    .foregroundStyle(symbol.priceColor)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: symbol.formattedPrice)

                Text(symbol.directionArrow)
                    .font(.title2.bold())
                    .foregroundStyle(symbol.priceIndicatorColor)
                    .contentTransition(.interpolate)
                    .animation(.easeInOut(duration: 0.4), value: symbol.priceDirection)
            }

            HStack {
                Text(symbol.companyName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    func descriptionSection(_ symbol: StockSymbol) -> some View {
        Section("About") {
            Text(symbol.companyDescription)
                .font(.body)
                .foregroundStyle(.primary)
        }
    }
}
