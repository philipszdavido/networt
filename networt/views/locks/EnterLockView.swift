//
//  EnterLockView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct EnterLockView: View {

    @State var lockCodes = ["", "", "", ""]
    @EnvironmentObject var settings: GlobalSettings
    
    func isLockCodesComplete() -> Bool {
        let index = lockCodes.first { lockCode in
            lockCode.isEmpty
        }
        
        if((index) != nil) {
            return false
        }
        return true
    }
    
    func onClick(value: String) {
        
        if(value == "erase") {
            
            let lockCodeIndex = lockCodes.lastIndex(where: { item in
                !item.isEmpty
            })
            
            if(lockCodeIndex != nil) {
                lockCodes[lockCodeIndex!] = ""
            }

            return
        } else {
            let lockCodeIndex = lockCodes.firstIndex(where: { item in
                item.isEmpty
            })
            
            if(lockCodeIndex != nil) {
                lockCodes[lockCodeIndex!] = value
            }
        }
        
        // check if lockCodes is complete
        if(isLockCodesComplete()) {
            
            if(settings.lockCodes == lockCodes.joined()) {
                
                settings.lockCodes = lockCodes.joined()
                settings.isLockCodeSet = true

            } else {
                emptyLockCodes()
            }
        }
        
        
    }
    
    func emptyLockCodes() {
        lockCodes = ["", "", "", ""]
    }
    
    var body: some View {
        
        Text("Welcome").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).padding()
        //Text(settings.lockCodes)
        //Text(lockCodes.joined())
        
        //Text(String(settings.isLockCodeSet))
        
        HStack {
            ForEach(lockCodes, id: \.self) { item in
                Circle()
                    .foregroundColor(item.isEmpty ? .secondary : .black)
                    .frame(width: 10)
            }
        }
        
        Text("Enter your lock code")
        
        LockGridView(onClick: onClick)
    }
}


#Preview {
    EnterLockView()
}
