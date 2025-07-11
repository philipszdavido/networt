//
//  RealEstateTrackerView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import SwiftData
import MapKit

// MARK: - RealEstateTrackerViewV2
struct RealEstateTrackerViewV2: View {
    @Query private var properties: [Property]
    @State private var showingAddProperty = false
    @State private var sortOption: String = "roi"

    var sortedProperties: [Property] {
        switch sortOption {
        case "roi": return properties.sorted { $0.roi > $1.roi }
        case "gain": return properties.sorted { $0.gain > $1.gain }
        default: return properties
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedProperties) { property in
                    NavigationLink(destination: PropertyDetailView(property: property)) {
                        VStack(alignment: .leading) {
                            Text(property.name).font(.headline)
                            Text("ROI: \(property.roi, specifier: "%.2f")% | Gain: $\(property.gain, specifier: "%.0f")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        showingAddProperty = true
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Picker("Sort", selection: $sortOption) {
                        Text("ROI").tag("roi")
                        Text("Gain").tag("gain")
                    }.pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Properties")
            .sheet(isPresented: $showingAddProperty) {
                AddPropertyView()
            }
        }
    }
}

#Preview {
    RealEstateTrackerViewV2()
        .modelContainer(for: [Property.self, RentalIncome.self])
}
