//
//  PropertyDetailView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import Charts
import SwiftData
import MapKit

struct PropertyDetailView: View {
    var property: Property

    var appreciationData: [AppreciationPoint] {
        var data: [AppreciationPoint] = []
        var value = property.purchasePrice
        let rate = property.appreciationPercent / 100
        let currency = property.currency

        for year in 1...10 {
            value *= (1 + rate)
            data
                .append(
                    AppreciationPoint(
                        year: year,
                        currency: currency,
                        estimatedValue: value
                    )
                )
        }
        return data
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("\(property.name)")
                    .font(.largeTitle)
                Text("Purchase: \(property.purchasePrice, format: .currency(code: property.currency).precision(.fractionLength(0)))")
                Text("Market: \(property.marketValue, format: .currency(code: property.currency))")

                Text("Appreciation: \(property.appreciationPercent, specifier: "%.1f")%")

                Chart(appreciationData) {
                    LineMark(
                        x: .value("Year", $0.year),
                        y: .value("Estimated Value", $0.estimatedValue)
                    )
                }
                .frame(height: 200)

                if let lat = property.latitude, let lon = property.longitude {
                    Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))), annotationItems: [property]) { _ in
                        MapMarker(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                    }
                    .frame(height: 200)
                }
            }
            .padding()
        }
    }
}

#Preview {
    PropertyDetailView(
        property: Property(
            name: "Rent",
            currency: "ngn",
            purchasePrice: 0.0,
            marketValue: 0.0,
            appreciationPercent: 0.0
        )
    )
}
