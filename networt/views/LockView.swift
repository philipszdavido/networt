//
//  LockView.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/8/24.
//

import SwiftUI

struct LockView: View {

    var newLockCode: Bool = true;
    
    var body: some View {
        if(newLockCode) {
            NewLockCodesView()
        } else {
            EnterLockView()
        }
    }
    
}

#Preview {
    LockView(newLockCode: true).environmentObject(GlobalSettings())
}


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
