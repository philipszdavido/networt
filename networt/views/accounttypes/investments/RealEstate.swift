//
//  RealEsttate.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import Foundation

struct RealEstate: View {
    @EnvironmentObject var settings: GlobalSettings

    @StateObject private var vm = RealEstateViewModel()
        
        @State private var name = ""
        @State private var purchasePrice = ""
        @State private var marketValue = ""
        @State private var appreciation = ""
        @State private var currency: String = "usd"

    var body: some View {
        VStack(alignment: .leading) {
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text("Enter Investments").font(.system(size: 30, weight: .bold, design: settings.fontDesign))
                    Spacer()
                }
                
                Text("Support for multiple subtypes: Stocks, Cryptocurrency, Real Estate"
                )
                .fontDesign(settings.fontDesign)
                
            }
            .padding(.bottom)
            .padding(.horizontal)

            CurrencySelector(currency: $currency)
                .padding([.horizontal, .bottom])
                .font(
                    .system(size: 20, weight: .semibold, design: settings.fontDesign)
                )

            // MARK: - "Purchase Price"
            TextFieldView(
                name: "Property Name",
                placeholder: "Property Name",
                value: $name
            )

            // MARK: - "Purchase Price"
            TextFieldView(
                name: "Purchase Price",
                placeholder: "Purchase Price",
                value: $purchasePrice
            )
            
            
            // MARK: - "Market Value"
            TextFieldView(
                name: "Market Value",
                placeholder: "Market Value",
                value: $marketValue
            )
            
            
            // MARK: - "Annual Appreciation %"
            TextFieldView(name: "Annual Appreciation %", placeholder: "Annual Appreciation %", value: $appreciation)
            
            // List of Properties
            List($vm.properties) { $property in
                NavigationLink {
                    PropertyDetailView(property: property)
                } label: {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(property.name)
                            .font(.headline)
                        Text("Purchase: \(property.purchasePrice, format: .currency(code: property.currency))")
                            Text("Market: \(property.marketValue, format: .currency(code: property.currency))")
                            Text("Gain: \(property.gain, format: .currency(code: property.currency))")
                                .foregroundColor(property.gain >= 0 ? .green : .red)
                        Text("ROI: \(property.roi, specifier: "%.2f")%")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
                
            }
                        
        }.toolbar {
            ToolbarItem(
                placement: ToolbarItemPlacement.topBarTrailing) {
                    Button {
                        addProperty()
                    } label: {
                        Text("Add Property")
                    }

                }
        }

    }
    
    func addProperty() {

        if let purchase = Double(purchasePrice),
           let market = Double(marketValue),
           let appr = Double(appreciation) {
            print(purchase, market, appr)
            vm
                .addProperty(
                    name: name,
                    currency: currency,
                    purchasePrice: purchase,
                    marketValue: market,
                    appreciation: appr
                )
            name = ""; purchasePrice = ""; marketValue = ""; appreciation = ""
        }
    }
}

#Preview {
    NavigationStack {
        
        RealEstate()
    }
        .environmentObject(GlobalSettings())
}

struct RealEstateTrackerView: View {
    @StateObject private var vm = RealEstateViewModel()
    
    @State private var name = ""
    @State private var purchasePrice = ""
    @State private var marketValue = ""
    @State private var appreciation = ""
    @State private var currency: String = "usd"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Input Fields
                CurrencySelector(currency: $currency)
                TextField("Property Name or Location", text: $name)
                    .textFieldStyle(.roundedBorder)
                TextField("Purchase Price", text: $purchasePrice)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                TextField("Market Value", text: $marketValue)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                TextField("Annual Appreciation %", text: $appreciation)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)

                // Add Button
                Button("Add Property") {
                    if let purchase = Double(purchasePrice),
                       let market = Double(marketValue),
                       let appr = Double(appreciation) {
                        vm
                            .addProperty(
                                name: name,
                                currency: currency,
                                purchasePrice: purchase,
                                marketValue: market,
                                appreciation: appr
                            )
                        name = ""; purchasePrice = ""; marketValue = ""; appreciation = ""
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || Double(purchasePrice) == nil || Double(marketValue) == nil)

                // List of Properties
                List(vm.properties) { property in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(property.name)
                            .font(.headline)
                        Text("Purchase: \(property.purchasePrice, format: .currency(code: property.currency))")
                        Text("Market: \(property.marketValue, format: .currency(code: property.currency))")
                        Text("Gain: \(property.gain, format: .currency(code: property.currency))")
                            .foregroundColor(property.gain >= 0 ? .green : .red)
                        Text("ROI: \(property.roi, specifier: "%.2f")%")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .navigationTitle("Real Estate Tracker")
        }
    }
}


#Preview {
    NavigationStack {
        
        RealEstateTrackerView()
    }
        .environmentObject(GlobalSettings())
}

struct TextFieldView: View {

    private let cornerRadius: CGFloat = 1.0

    var name: String
    var placeholder: String;
    @Binding var value: String;
    @EnvironmentObject var settings: GlobalSettings
    
    var body: some View {
                
        VStack(alignment: .leading) {
            
            Text("\(name)")
                .font(
                    .system(
                        size: 15,
                        weight: .semibold,
                        design: settings.fontDesign
                    )
                )
                .padding(.horizontal)
                .foregroundColor(.gray)
            
            VStack {
                TextField("\(placeholder)", text: $value)
                    .padding(10.0)
                    .contentMargins(1.0)
                    .textContentType(.name)
                    .font(.system(size: 20, weight: .semibold, design: settings.fontDesign))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .foregroundColor(.primary)
                    .keyboardType(.numberPad)
            }.padding(.horizontal)
            
            Divider()
            
        }
        
    }
}
