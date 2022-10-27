//
//  DateCalculator.swift
//  SimpleHabit
//
//  Created by Val V on 27/08/21.
//

import Foundation

struct DateCalculator{
    
    static func getNextDate(freq:Int) ->Date {
        // Get right now as it's `DateComponents`.
        let now = Calendar.current.dateComponents(in: .autoupdatingCurrent, from:Date())

                // Don't worry about month and year wraps, the API handles that.
        let next = DateComponents(year: now.year, month: now.month, day: now.day! + freq)
        let dateNext = Calendar.current.date(from: next)!
        print(dateNext)
        return dateNext
    }
    
    static func returnTimeInterval(date:Date) ->TimeInterval {
        return Date().timeIntervalSince(date)
    }
    
    static func canStartTimer(date:Date) ->Bool {
        
        let t = (Date().timeIntervalSince(date))
        print(t)
        if t>0 && t<86400{
            print("Within Today")
            return true
        }
        else{
            print("Not within today")
            return false
        }
    }
    
}


  // Extension

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}
