//
//  Investments.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct Investments: View {
    @EnvironmentObject var settings: GlobalSettings

    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text("Enter Investments").font(.system(size: 30, weight: .bold, design: settings.fontDesign))
                    Spacer()
                }
                
                Text("Support for multiple subtypes: Stocks, Cryptocurrency, Real Estate"
                )
                .fontDesign(settings.fontDesign)
                
            }.padding(.bottom)
                .padding(.horizontal)
            
            List {
                NavigationLink {
                    Stocks()
                } label: {
                    Text("Stocks")
                }
                                
                NavigationLink {
                    Cryptocurrency()
                } label: {
                    Text("Cryptocurrency")
                }

                NavigationLink {
                    RealEstate()
                } label: {
                    Text("Real Estate")
                }
                
                
                
                
            }.listStyle(.plain)
        }
    }
}

#Preview {
    NavigationView {
        
        Investments()
    }
        .environmentObject(GlobalSettings())

}
