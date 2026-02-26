//
//  StockFeedScreen.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import SwiftUI

struct StockFeedScreen: View {

    @StateObject private var viewModel: StockFeedViewModel

    init(viewModel: StockFeedViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            ForEach(viewModel.sortedTickers, id: \.self) { ticker in
                if let symbol = viewModel.tickersDictionary[ticker] {
                    ZStack {
                        NavigationLink {
                            StockDetailScreen(viewModel: viewModel, ticker: ticker)
                        } label: {
                            EmptyView()
                        }
                        .opacity(0)

                        StockRowView(symbol: symbol)
                    }
                }
            }
        }
        .listStyle(.plain)
        .animation(.default, value: viewModel.sortedTickers)
        .navigationTitle("Stock Feed")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                connectionStatusView
            }
            ToolbarItem(placement: .topBarTrailing) {
                toggleButton
            }
        }
    }
}

// MARK: - Subviews

private extension StockFeedScreen {
    var connectionStatusView: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 10, height: 10)
            .animation(.easeInOut(duration: 0.3), value: viewModel.feedState)
    }

    @ViewBuilder
    var toggleButton: some View {
        switch viewModel.feedState {
        case .disconnected:
            Button { viewModel.start() } label: {
                Image(systemName: "play.fill")
                    .foregroundStyle(.green)
            }
        case .connected:
            Button { viewModel.stop() } label: {
                Image(systemName: "stop.fill")
                    .foregroundStyle(.red)
            }
        case .connecting:
            ProgressView()
        }
    }
}

// MARK: - Helpers

private extension StockFeedScreen {
    var statusColor: Color {
        switch viewModel.feedState {
        case .connected: .green
        case .connecting: .gray
        case .disconnected: .red
        }
    }
}
