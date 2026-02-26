//
//  MultiBankGroupTaskApp.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import SwiftUI

@main
struct MultiBankGroupTaskApp: App {

    @State private var navigationPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                StockFeedScreen()
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
        }
    }
}

// MARK: - Deep Link

private extension MultiBankGroupTaskApp {
    func handleDeepLink(_ url: URL) {
        guard url.scheme == "stocks",
              url.host == "symbol",
              let ticker = url.pathComponents.dropFirst().first,
              StockSymbol.allSymbols.contains(where: { $0.id == ticker })
        else {
            return
        }
        navigationPath = NavigationPath()
        navigationPath.append(ticker)
    }
}
