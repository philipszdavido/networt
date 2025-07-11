//
//  LockGridView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct LockGridView: View {
    
    var onClick: (_ value: String) -> Void;
    
    let adaptiveColumn = [
        
            GridItem(.adaptive(minimum: 150)),
            GridItem(.adaptive(minimum: 150)),
            GridItem(.adaptive(minimum: 150))

        ]

    
    var body: some View {
        LazyVGrid(columns: adaptiveColumn, spacing: 20) {
            
            ForEach(1...9, id: \.self) { item in
                
                ButtonView(text: String(item), onClick: onClick)
                
            }
            
            Spacer()

            ButtonView(text: "0", onClick: onClick)

            ButtonView(text: "erase", image: "eraser", onClick: onClick)
            
        }.padding(50)
    }
}

#Preview {
    LockGridView(onClick: { _ in })
}
