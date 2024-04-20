//
//  Time.swift
//  networt
//
//  Created by Chidume Nnamdi on 4/20/24.
//

import Foundation

class Time {
    static func formatDateTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, h:mm a"
        
        _ = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday, " + dateFormatter.string(from: date)
        } else if Calendar.current.isDateInToday(date) {
            return "Today, " + dateFormatter.string(from: date)
        } else {
            return dateFormatter.string(from: date)
        }
    }
    
    static func dateFromString(_ string: String) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate] // Added format options
        let date = dateFormatter.date(from: string) ?? Date.now
        return date
    }

}
