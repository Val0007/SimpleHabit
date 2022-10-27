//
//  Habit.swift
//  SimpleHabit
//
//  Created by Val V on 20/08/21.
//

import Foundation

struct Habit {
    let id:String
    var name:String
    var time:Int
    var streak :Int = 0
    var frequency:Int
    var nextDate:Date?
}
