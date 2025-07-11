//
//  ButtonView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct ButtonView: View {
    
    var text: String;
    var image: String?;
    
    var onClick: (_ value: String) -> Void;
    
    var body: some View {

        Button(action: {
            onClick(text)
        }) {
            Circle()
                .padding(5.0)
                .frame(width: nil)
                .overlay {
                    if(image != nil) {
                        
                        Image(systemName: image!).foregroundStyle(.white).font(.system(size: 30.0))

                    }
                    
                    else {
                            Text("\(text)")
                                .font(.system(size: 30.0)).foregroundColor(.white)
                        
                    }
                }
            
        }.foregroundColor(.gray)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0.3)) {
                    onClick(text)
                }
            }
    }
}

#Preview {
    ButtonView(text: "Enter", onClick: { _ in })
}
