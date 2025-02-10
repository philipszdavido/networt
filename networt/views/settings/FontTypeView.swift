//
//  FontTypeView.swift
//  networt
//
//  Created by Chidume Nnamdi on 10/02/2025.
//

import SwiftUI

struct FontTypeView: View {
    
    @ObservedObject var settings: GlobalSettings;
        
    var body: some View {
        
        List {
            Toggle(isOn: Binding(
                get: { settings.fontDesign == .default },
                set: { isOn in
                    settings.fontDesign = isOn ? .default : .default
                }
            )) {
                Text("Default")
                    .font(.system(Font.TextStyle.callout, design: .default))
            }
            
            Toggle(isOn: Binding(
                get: { settings.fontDesign == .serif },
                set: { isOn in
                    settings.fontDesign = isOn ? .serif : .default
                }
            )) {
                Text("Serif")
                    .font(.system(Font.TextStyle.callout, design: .serif))
            }
            
            Toggle(isOn: Binding(
                get: { settings.fontDesign == .monospaced },
                set: { isOn in
                    settings.fontDesign = isOn ? .monospaced : .default
                }
            )) {
                Text("Monospaced")
                    .font(.system(Font.TextStyle.callout, design: .monospaced))
            }
            
            Toggle(isOn: Binding(
                get: { settings.fontDesign == .rounded },
                set: { isOn in
                    settings.fontDesign = isOn ? .rounded : .default
                }
            )) {
                Text("Rounded")
                    .font(.system(Font.TextStyle.callout, design: .rounded))
            }

        }
        
    }
}

#Preview {
    FontTypeView(settings: GlobalSettings())
}
