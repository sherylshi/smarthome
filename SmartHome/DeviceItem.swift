//
//  DeviceItem.swift
//  SmartHome
//
//  Created by Jian Tian on 4/30/17.
//  Copyright © 2017 Jian Tian. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct DeviceItem {
    
    let key: String
    var notificationList = [Notification]()
//    let message: String
//    let timestamp: String
//    let ref: FIRDatabaseReference?
//    var completed: Bool
    
//    init(message: String, timestamp: String, key: String = "") {
//        self.key = key
//        self.message = message
//        self.timestamp = timestamp
//        self.completed = completed
//        self.ref = nil
//    }
    
    init(key: String) {
        self.key = key
        notificationList = []
//        self.completed = ""
//        self.ref = nil
    }
    
//    init(key: String, notification: Notification) {
//        self.key = key
//        self.notificationList.append(notification)
////        self.ref = nil
//    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
//        message = "test" as String
//        timestamp = "2010:09" as String
//        timestamp = snapshotValue["timestamp"] as! String
//        completed = true //snapshotValue["completed"] as! Bool
//        ref = snapshot.ref
    }
    
    mutating func addNotification(notification: Notification) {
        self.notificationList.append(notification)
    }
    
    func toAnyObject() -> Any {
        return [
            "key": key
//            "message": message,
//            "timestamp": timestamp
//            "completed": completed?
        ]
    }
    
}
