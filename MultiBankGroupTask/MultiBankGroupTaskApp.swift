//
//  MultiBankGroupTaskApp.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import SwiftUI

@main
struct MultiBankGroupTaskApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StockFeedScreen(viewModel: buildStockFeedViewModel())
            }
        }
    }

    private func buildStockFeedViewModel() -> StockFeedViewModel {
        let tickers = StockSymbol.allSymbols
        let webSocketService = WebSocketService()
        let priceGenerator = StockPriceGenerator(tickers: tickers)
        return StockFeedViewModel(tickers: tickers, webSocketService: webSocketService, priceGenerator: priceGenerator)
    }
}
