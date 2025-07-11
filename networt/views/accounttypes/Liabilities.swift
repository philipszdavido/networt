//
//  Liabilities.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct Liabilities: View {
    
    @EnvironmentObject var settings: GlobalSettings

    var body: some View {
        
        VStack {
            
            HStack {
                Text("Enter Liabilities").font(.system(size: 30, weight: .bold, design: settings.fontDesign))
                Spacer()
            }

            Text(
                "Track debt such as: Loans and Credit Cards"
            )
            .fontDesign(settings.fontDesign)
            
        }
        .padding(.bottom)
        .padding(.horizontal)

    }
}

#Preview {
    Liabilities()
        .environmentObject(GlobalSettings())

}
