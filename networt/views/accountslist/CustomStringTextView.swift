//
//  CustomStringTextView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct CustomStringTextView: View {
    
    var text: String;
    @Binding var link: String;
    
    var keyboardType: UIKeyboardType = UIKeyboardType.default
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

                TextField("\(text)", text: $link)
                .keyboardType(keyboardType)
                .disableAutocorrection(true)
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
    CustomStringTextView(text: "Text", link: .constant("text"))
        .environmentObject(GlobalSettings())
}
