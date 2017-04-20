//
//  VGNotification.swift
//  VGClient
//
//  Created by viwii on 2017/4/19.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit


struct VGNotificationManager {
    
    
    func schedule(title: String, body: String, userInfo: [AnyHashable : Any], minute: Int? = 0) {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default()
            
            var date = Date(timeIntervalSinceNow: TimeInterval(minute! * 60))
            let dateComponents = Calendar.current.dateComponents([.year,.month,.day,.month,.hour,.minute,.second], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: Date().description, content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request, withCompletionHandler: { (error) in
                print(self, #function, error?.localizedDescription ?? "no error")
            })
        } else {
            let notification = UILocalNotification()
            notification.fireDate = Date(timeIntervalSinceNow: TimeInterval(minute! * 60))
            notification.alertBody = body
            notification.alertTitle = title
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
        }
        
        
        
    }
    
    
}
