//
//  PieChartView.swift
//  networt
//
//  Created by Chidume Nnamdi on 11/07/2025.
//

import SwiftUI
import SwiftData
import Charts

// MARK: - Pie Chart
struct PieChartView: View {
    var liabilities: [Liability]

    var body: some View {
        Chart {
            ForEach(LiabilityType.allCases) { type in
                let total = liabilities.filter { $0.type == type }.map { $0.balance }.reduce(0, +)
                if total > 0 {
                    SectorMark(
                        angle: .value("Balance", total),
                        innerRadius: .ratio(0.6),
                        angularInset: 1.0
                    )
                    .foregroundStyle(by: .value("Type", type.rawValue))
                }
            }
        }
        .chartLegend(position: .bottom)
        .padding()
    }
}

//#Preview {
//    PieChartView()
//}
