//
//  Cash.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct CashView: View {
    
    @State var amount: String = "0";
    @State var currency: String = "USD"
    
    private let cornerRadius: CGFloat = 2;
    
    @EnvironmentObject var settings: GlobalSettings
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        VStack(alignment: .leading) {
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text("Enter Cash").font(.system(size: 30, weight: .bold, design: settings.fontDesign))
                    Spacer()
                }
                
                Text(
                    "Let users manually record cash on hand (e.g., physical wallet money)."
                )
                .fontDesign(settings.fontDesign)
                
            }.padding(.bottom)
                .padding(.horizontal)
            
            VStack {
                
                NavigationLink(destination: CurrencyListPickerView(selection: $currency)) {
                    
                    HStack {
                        Text("Currency: \(currency.uppercased())")
                            .font(
                                .system(
                                    size: 20,
                                    weight: .semibold,
                                    design: settings.fontDesign
                                        )
                            )
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    
                }
            }.padding(.horizontal)
                .padding(.bottom)
            
            VStack(alignment: .leading) {
                
                Text("Amount")
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
                    TextField("Amount, e.g 400", text: $amount)
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
            
            Spacer()
        }
        .toolbar {
            ToolbarItem(
                placement: ToolbarItemPlacement.topBarTrailing) {
                    Button {
                        addCash()
                    } label: {
                        Text("Add Cash")
                    }

                }
        }
    }
    
    func addCash() {
        let cash = Cash(amount: Double(amount) ?? 0.0, currency: currency)
        modelContext.insert(cash)
    }
}

#Preview {
    NavigationStack {
        CashView()
    }
        .environmentObject(GlobalSettings())
}
