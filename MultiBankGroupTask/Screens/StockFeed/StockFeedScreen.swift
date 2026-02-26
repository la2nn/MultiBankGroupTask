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
                    StockRowView(symbol: symbol)
                }
            }
        }
        .listStyle(.plain)
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
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            Text(statusText)
                .font(.caption)
        }
    }

    var toggleButton: some View {
        Button(action: {
            switch viewModel.feedState {
            case .disconnected:
                viewModel.start()
            case .connected:
                viewModel.stop()
            case .connecting:
                break
            }
        }) {
            Text(buttonTitle)
        }
        .disabled(viewModel.feedState == .connecting)
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

    var statusText: String {
        switch viewModel.feedState {
        case .connected: "Connected"
        case .connecting: "Connecting..."
        case .disconnected: "Disconnected"
        }
    }

    var buttonTitle: String {
        switch viewModel.feedState {
        case .connected: "Stop"
        case .connecting: "Connecting..."
        case .disconnected: "Start"
        }
    }
}
