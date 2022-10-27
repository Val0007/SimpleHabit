//
//  DatabaseServices.swift
//  SimpleHabit
//
//  Created by Val V on 06/10/21.
//

import Foundation
import CloudKit

struct DatabaseServices {
    
    private let database  = CKContainer(identifier: "").privateCloudDatabase
    
    static let shared = DatabaseServices()
    
    func saveHabit(habitToBeSet:Habit,completion:@escaping(Bool)->()){
        let habit:CKRecord = CKRecord(recordType: "Habit")
        habit.setValue(habitToBeSet.id, forKey: "id")
        habit.setValue(habitToBeSet.name, forKey: "name")
        habit.setValue(habitToBeSet.time, forKey: "time")
        habit.setValue(habitToBeSet.streak, forKey: "streak")
        habit.setValue(habitToBeSet.frequency, forKey: "frequency")
        habit.setValue(habitToBeSet.nextDate, forKey: "nextDate") //nil while saving
        database.save(habit) { (record, err) in
            if(err != nil){
                completion(false)
                return
            }
            if record != nil{
                completion(true)
                print(record)
            }
        }
    }
    
    
    func deleteHabit(habit:Habit,completion:@escaping(Bool)->()){
        let query = CKQuery(recordType: "Habit", predicate: NSPredicate(format: "id = %@", habit.id))
        database.perform(query, inZoneWith: nil) { records, err in
            if err != nil{
                completion(false)
                return
            }
            if records != [] {
                guard let records = records else {return}
                let habitToBeDeleted = records[0]
                database.delete(withRecordID: habitToBeDeleted.recordID) { id, err in
                    if err != nil {
                        completion(false)
                    }
                    if id != nil {
                        completion(true)
                    }
                }

            }
            else{
                completion(false)
            }
        }
    }
    
    func editHabit(habit:Habit,completion:@escaping(Bool)->()){
        print(habit.id)
        let query = CKQuery(recordType: "Habit", predicate: NSPredicate(format: "id = %@", habit.id))
        database.perform(query, inZoneWith: nil) { (records, err) in
            if records != []{
                guard let recordss = records else {return}
                let habitToBeEdited = recordss[0]
                habitToBeEdited.setValue(habit.id, forKey: "id")
                habitToBeEdited.setValue(habit.name, forKey: "name")
                habitToBeEdited.setValue(habit.time, forKey: "time")
                habitToBeEdited.setValue(habit.streak, forKey: "streak")
                habitToBeEdited.setValue(habit.frequency, forKey: "frequency")
                habitToBeEdited.setValue(habit.nextDate, forKey: "nextDate")
                database.save(habitToBeEdited) { (record, err) in
                    
                    if err == nil{
                        completion(true)
                    }
                    else{
                        completion(false)
                    }
                }
            }
            else{
                print("ERROR")
                completion(false)
            }
        }
    }
    
    func fetchHabits(completion:@escaping([Habit]?)->()){
        let query = CKQuery(recordType: "Habit", predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { (records, err) in
            
            if err != nil{
                print(err?.localizedDescription)
                print("NETWORK ERROR")
                completion(nil)
                return
            }
            
            if records != nil{
                let habits = records?.compactMap({ (record) -> Habit in
                    var habit = Habit(id: record.value(forKey: "id") as! String, name: record.value(forKey: "name") as! String, time: record.value(forKey: "time") as! Int,streak: record.value(forKey: "streak") as! Int ,frequency: record.value(forKey: "frequency") as! Int)
                    if let nextDate  = record.value(forKey: "nextDate") as? Date {
                        habit.nextDate = nextDate
                    }
                    else{
                        habit.nextDate = nil
                    }
                    
                    return habit
                })
                guard let habitRecords  = habits else {return}
                completion(habitRecords)

            }

            
        }
        
    }
    

    
}








//struct Habit {
//    var name:String
//    var time:Int
//    var streak :Int = 0
//    var frequency:Int
//    var nextDate:Date?
//}
