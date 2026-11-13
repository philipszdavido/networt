//
//  CryptoModels.swift
//  networt
//
//  Created by Chidume Nnamdi on 12/07/2025.
//

import Foundation
import SwiftData

/// A CoinGecko coin and its last known USD price.
@Model
class Coin: Decodable, Identifiable {
    var id: String = ""
    var symbol: String = ""
    var name: String = ""
    var current_price: Double = 0
    var priceUpdatedAt: Date?

    @Relationship(deleteRule: .nullify, inverse: \CoinHolding.coin) var holdings: [CoinHolding]? = []

    init(id: String, symbol: String, name: String, current_price: Double) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.current_price = current_price
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(String.self, forKey: .id),
            symbol: try container.decode(String.self, forKey: .symbol),
            name: try container.decode(String.self, forKey: .name),
            current_price: try container.decode(Double.self, forKey: .current_price)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case current_price
    }
}

@Model
class CoinHolding: Identifiable {
    var id = UUID()
    var coin: Coin?
    var amount: Double = 0
    /// Purchase price per coin, in USD.
    var costBasis: Double?

    init(coin: Coin, amount: Double) {
        self.coin = coin
        self.amount = amount
    }

    var name: String { coin?.name ?? "Unknown coin" }
    var symbol: String { coin?.symbol.uppercased() ?? "" }
    var price: Double { coin?.current_price ?? 0 }

    var totalValue: Double {
        amount * price
    }

    var unrealizedGain: Double? {
        costBasis.map { (price - $0) * amount }
    }
}
