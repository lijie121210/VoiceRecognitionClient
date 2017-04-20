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


struct VGNotification {
    
    var title: String
    var body: String
    var lunchImageName: String
    
    func schedule(minute: Int, userInfo: [AnyHashable : Any] = [:]) {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default()
            content.launchImageName = lunchImageName
            content.userInfo = userInfo
            
            let date = Date(timeIntervalSinceNow: TimeInterval(minute * 60))
            let dateComponents = Calendar.current.dateComponents([.year,.month,.day,.month,.hour,.minute,.second], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: Date().description, content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            if let navi = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
                let del = navi.topViewController as? UNUserNotificationCenterDelegate {
                center.delegate = del
            }
            center.add(request, withCompletionHandler: { (error) in
                print(self, #function, error?.localizedDescription ?? "no error")
            })
        } else {
            let notification = UILocalNotification()
            notification.fireDate = Date(timeIntervalSinceNow: TimeInterval(minute * 60))
            notification.alertBody = body
            notification.alertTitle = title
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
        } 
    }
    
    
}
