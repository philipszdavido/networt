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
