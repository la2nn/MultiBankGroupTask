//
//  StockSymbol.swift
//  MultiBankGroupTask
//
//  Created by Nikolay Spiridonov on 26.02.2026.
//

import Foundation

nonisolated struct StockSymbol: Identifiable, Equatable {
    enum PriceDirection {
        case up
        case down
        case none
    }

    let id: String // id == ticker
    let companyName: String
    let companyDescription: String

    private(set) var currentPrice: Decimal
    private(set) var previousPrice: Decimal
    private(set) var priceDirection: PriceDirection
    private(set) var formattedPrice: String

    init(id: String, companyName: String, companyDescription: String, currentPrice: Decimal) {
        self.id = id
        self.companyName = companyName
        self.companyDescription = companyDescription
        self.currentPrice = currentPrice
        self.previousPrice = currentPrice
        self.priceDirection = .none
        self.formattedPrice = StockSymbol.priceFormatter.string(from: currentPrice as NSDecimalNumber) ?? ""
    }

    mutating func applyPriceUpdate(_ newPrice: Decimal) {
        previousPrice = currentPrice
        currentPrice = newPrice
        formattedPrice = StockSymbol.priceFormatter.string(from: newPrice as NSDecimalNumber) ?? ""
        if currentPrice > previousPrice {
            priceDirection = .up
        } else if currentPrice < previousPrice {
            priceDirection = .down
        } else {
            priceDirection = .none
        }
    }

    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

// MARK: - Mock Data

nonisolated extension StockSymbol {
    static let allSymbols: [StockSymbol] = [
        StockSymbol(
            id: "AAPL",
            companyName: "Apple Inc.",
            companyDescription: "Apple designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide.",
            currentPrice: 178.72,
        ),
        StockSymbol(
            id: "GOOG",
            companyName: "Alphabet Inc.",
            companyDescription: "Alphabet is a multinational conglomerate and parent company of Google, specializing in internet services, cloud computing, and AI.",
            currentPrice: 141.80,
        ),
        StockSymbol(
            id: "TSLA",
            companyName: "Tesla Inc.",
            companyDescription: "Tesla designs, develops, manufactures, and sells electric vehicles, energy storage systems, and solar products.",
            currentPrice: 248.42,
        ),
        StockSymbol(
            id: "AMZN",
            companyName: "Amazon.com Inc.",
            companyDescription: "Amazon is a global technology company focused on e-commerce, cloud computing (AWS), digital streaming, and artificial intelligence.",
            currentPrice: 178.25,
        ),
        StockSymbol(
            id: "MSFT",
            companyName: "Microsoft Corp.",
            companyDescription: "Microsoft develops and supports software, services, devices, and solutions including Windows, Azure, and Office 365.",
            currentPrice: 388.47,
        ),
        StockSymbol(
            id: "NVDA",
            companyName: "NVIDIA Corp.",
            companyDescription: "NVIDIA designs GPU-accelerated computing platforms for gaming, data centers, automotive, and AI applications.",
            currentPrice: 495.22,
        ),
        StockSymbol(
            id: "META",
            companyName: "Meta Platforms Inc.",
            companyDescription: "Meta builds technologies that help people connect through its family of apps including Facebook, Instagram, and WhatsApp.",
            currentPrice: 367.46,
        ),
        StockSymbol(
            id: "NFLX",
            companyName: "Netflix Inc.",
            companyDescription: "Netflix is a streaming entertainment service offering TV series, documentaries, feature films, and mobile games.",
            currentPrice: 486.88,
        ),
        StockSymbol(
            id: "JPM",
            companyName: "JPMorgan Chase & Co.",
            companyDescription: "JPMorgan Chase is a global financial services firm offering investment banking, asset management, and consumer banking.",
            currentPrice: 172.96,
        ),
        StockSymbol(
            id: "V",
            companyName: "Visa Inc.",
            companyDescription: "Visa operates a global payments technology network facilitating electronic funds transfers worldwide.",
            currentPrice: 272.18,
        ),
        StockSymbol(
            id: "MA",
            companyName: "Mastercard Inc.",
            companyDescription: "Mastercard is a global technology company in the payments industry connecting consumers, businesses, and governments.",
            currentPrice: 428.30,
        ),
        StockSymbol(
            id: "DIS",
            companyName: "The Walt Disney Co.",
            companyDescription: "Disney is a diversified entertainment company operating theme parks, media networks, and streaming platforms.",
            currentPrice: 93.64,
        ),
        StockSymbol(
            id: "PYPL",
            companyName: "PayPal Holdings Inc.",
            companyDescription: "PayPal operates a digital payments platform enabling online money transfers and serving as an electronic alternative to traditional methods.",
            currentPrice: 62.47,
        ),
        StockSymbol(
            id: "INTC",
            companyName: "Intel Corp.",
            companyDescription: "Intel designs and manufactures semiconductor chips and related technologies for computing and communications.",
            currentPrice: 42.38,
        ),
        StockSymbol(
            id: "AMD",
            companyName: "Advanced Micro Devices Inc.",
            companyDescription: "AMD develops high-performance computing and graphics solutions for data centers, gaming, and embedded applications.",
            currentPrice: 148.93,
        ),
        StockSymbol(
            id: "CRM",
            companyName: "Salesforce Inc.",
            companyDescription: "Salesforce provides cloud-based customer relationship management software and enterprise applications.",
            currentPrice: 272.65,
        ),
        StockSymbol(
            id: "ORCL",
            companyName: "Oracle Corp.",
            companyDescription: "Oracle provides cloud infrastructure, database management systems, and enterprise software products worldwide.",
            currentPrice: 118.24,
        ),
        StockSymbol(
            id: "CSCO",
            companyName: "Cisco Systems Inc.",
            companyDescription: "Cisco designs, manufactures, and sells networking hardware, software, and telecommunications equipment.",
            currentPrice: 50.87,
        ),
        StockSymbol(
            id: "ADBE",
            companyName: "Adobe Inc.",
            companyDescription: "Adobe provides digital media and marketing solutions including Creative Cloud, Document Cloud, and Experience Cloud.",
            currentPrice: 570.32,
        ),
        StockSymbol(
            id: "UBER",
            companyName: "Uber Technologies Inc.",
            companyDescription: "Uber operates a platform connecting riders with drivers, offering ride-hailing, food delivery, and freight services.",
            currentPrice: 61.58,
        ),
        StockSymbol(
            id: "BA",
            companyName: "The Boeing Co.",
            companyDescription: "Boeing designs, manufactures, and sells airplanes, rotorcraft, rockets, satellites, and related systems worldwide.",
            currentPrice: 216.74,
        ),
        StockSymbol(
            id: "SBUX",
            companyName: "Starbucks Corp.",
            companyDescription: "Starbucks operates an international chain of coffeehouses and roastery reserves, selling specialty coffee and food items.",
            currentPrice: 97.82,
        ),
        StockSymbol(
            id: "NKE",
            companyName: "Nike Inc.",
            companyDescription: "Nike designs, develops, and markets athletic footwear, apparel, equipment, and accessories globally.",
            currentPrice: 106.23,
        ),
        StockSymbol(
            id: "SNAP",
            companyName: "Snap Inc.",
            companyDescription: "Snap operates Snapchat, a visual messaging and camera platform for communication and augmented reality experiences.",
            currentPrice: 14.67,
        ),
        StockSymbol(
            id: "SPOT",
            companyName: "Spotify Technology S.A.",
            companyDescription: "Spotify is a digital music streaming service providing access to millions of songs, podcasts, and videos.",
            currentPrice: 188.94,
        )
    ]
}
