//
//  LiabilitiesBindings.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import SwiftUICore


// MARK: - Binding Helpers
extension Binding where Value == Double? {
    init(_ source: Binding<Double?>, default defaultValue: Double) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}

extension Binding where Value == Date? {
    init(_ source: Binding<Date?>, _ defaultValue: Date) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}
