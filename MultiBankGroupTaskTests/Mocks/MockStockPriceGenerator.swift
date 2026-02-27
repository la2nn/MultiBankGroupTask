//
//  MockStockPriceGenerator.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

@testable import MultiBankGroupTask

final class MockStockPriceGenerator: StockPriceGeneratorProtocol, @unchecked Sendable {

    private(set) var startEmittingCallCount = 0
    private(set) var stopEmittingCallCount = 0

    var onStartEmitting: (() -> Void)?
    var onStopEmitting: (() -> Void)?

    func startEmitting(to service: WebSocketServiceProtocol) async {
        startEmittingCallCount += 1
        onStartEmitting?()
    }

    func stopEmitting() async {
        stopEmittingCallCount += 1
        onStopEmitting?()
    }
}
