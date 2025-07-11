//
//  CustomNumberTextView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI


struct CustomNumberTextView: View {
    
    var text: String;
    @Binding var link: Int;
    @EnvironmentObject var settings: GlobalSettings

    var body: some View {
        VStack(alignment: .leading) {
            
            Text("\(text)")
                .font(
                    .system(
                        size: 20,
                        weight: .semibold,
                        design: settings.fontDesign
                    )
                )
                .padding(.horizontal)
                .foregroundColor(.gray)
                        
            TextField("\(text)", value: $link, format: .number)
                    .disableAutocorrection(true)
            .keyboardType(.numberPad)
            .font(
                .system(
                    size: 20,
                    weight: .semibold,
                    design: settings.fontDesign
                )
            )
                    .padding(.horizontal)
            
            Divider()
            
        }
    }
}

#Preview {
    CustomNumberTextView(text: "Text", link: .constant(45))
        .environmentObject(GlobalSettings())
}
