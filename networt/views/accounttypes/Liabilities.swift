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
                
        LiabilityListView()

    }
}

#Preview {
    
    NavigationStack {
        Liabilities()
    }
        .environmentObject(GlobalSettings())

}
