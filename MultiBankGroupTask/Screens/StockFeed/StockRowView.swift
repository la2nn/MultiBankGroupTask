//
//  StockRowView.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import SwiftUI

struct StockRowView: View {
    let symbol: StockSymbol

    @State private var isFlashing = false

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

            priceBadge
        }
        .padding(.vertical, 4)
        .onChange(of: symbol.currentPrice) { _ in
            triggerFlash()
        }
    }
}

// MARK: - Price Badge

private extension StockRowView {
    var priceBadge: some View {
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
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(symbol.priceColor.opacity(isFlashing ? 0.12 : 0))
        )
    }

    func triggerFlash() {
        guard symbol.priceDirection != .none else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isFlashing = true
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            withAnimation(.easeOut(duration: 0.6)) {
                isFlashing = false
            }
        }
    }
}
