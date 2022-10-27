//
//  LocalNotificationManager.swift
//  SimpleHabit
//
//  Created by Val V on 26/08/21.
//

import Foundation
import UserNotifications

struct Notification {
    var id: String
    var title: String
    var body:String
}

struct LocalNotificationManager{
    
    static let shared  = LocalNotificationManager()
    static let onGoingNotification:Bool  = false
    
   
    private func requestAuthorization(completion:@escaping(Bool)->()){
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in

            if granted == true && error == nil {
                completion(true)
            }
            else{
                completion(false)
            }
        }
    }
    
    private func scheduleNotification(notification:Notification,time:TimeInterval){
        let content  = UNMutableNotificationContent()
        content.title = notification.title
        content.body =  notification.body
        content.sound = .default
        
        let trigger  = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        let request  = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (err) in
            if let error  = err {
                print(error)
            }
        }
        
    }
    
    func schedule(notification:Notification,time:TimeInterval){
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            
            switch settings.authorizationStatus{
            case .authorized,.provisional:
                self.scheduleNotification(notification: notification, time: time)
            case .notDetermined,.denied:
                self.requestAuthorization { (bool) in
                    if bool{
                        self.scheduleNotification(notification: notification, time: time)
                    }
                }
            default:
                return
            }
            
        }
    }
    
}
