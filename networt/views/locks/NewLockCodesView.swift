//
//  NewLockCodesView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI

struct NewLockCodesView: View {

    @State var firstLockCodes = ["", "", "", ""]
    @State var secondLockCodes = ["", "", "", ""]
    
    @State var lockCodes = ["", "", "", ""]

    @EnvironmentObject var settings: GlobalSettings

    @State var round = 1
    
    func isLockCodesComplete() -> Bool {

        let index = lockCodes.first { lockCode in
            lockCode.isEmpty
        }
        
        if((index) != nil) {
            return false
        }
        return true
    }
    
    func process(value: String) {
        
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
            
            if(round == 1) {

                firstLockCodes = lockCodes
                lockCodes = ["", "", "", ""]

                round = 2
                
                return;
            }
            
            // check both codes are equal
            
            secondLockCodes = lockCodes
            
            if(firstLockCodes.joined() == secondLockCodes.joined()) {
                
                print("Good")
                
                settings.lockCodes = lockCodes.joined()
                
                settings.isLockCodeSet = true
                
            } else {
                print("They do not match")
                lockCodes = ["", "", "", ""]
                round = 1
            }
        }


    }
        
    func onClick(value: String) {
        
        process(value: value)

    }
        
    var body: some View {
        
        Text("Welcome").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).padding()
        
        HStack {
            ForEach(lockCodes, id: \.self) { item in
                Circle()
                    .foregroundColor(item.isEmpty ? .secondary : .black)
                    .frame(width: 10)
            }
        }
        
        round == 1 ? Text("Set your lock code") : Text("Re-enter your password")
        
        // Text(lockCodes.joined())
        
        LockGridView(onClick: onClick)
        
    }

}

#Preview {
    NewLockCodesView()
}
