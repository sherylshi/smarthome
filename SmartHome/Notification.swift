//
//  Notification.swift
//  SmartHome
//
//  Created by Jian Tian on 5/1/17.
//  Copyright © 2017 Jian Tian. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Notification {
    
    let key: String
    let audio: String
    var clientAudio: String
    var message: String
    let picture: String
    let timestamp: String
    var completed: Bool
    
    init(audio: String, clientAudio: String, message: String, picture: String, timestamp: String, completed: Bool, key: String = "") {
        self.key = key
        self.audio = audio
        self.clientAudio = clientAudio
        self.message = message
        self.picture = picture
        self.timestamp = timestamp
        self.completed = completed
    }
    
    init(key: String) {
        self.key = key
        self.audio = ""
        self.clientAudio = ""
        self.message = ""
        self.picture = ""
        self.timestamp = ""
        self.completed = false
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        audio = snapshotValue["audio"] as! String
        clientAudio = snapshotValue["clientAudio"] as! String
        message = snapshotValue["message"] as! String
        picture = snapshotValue["picture"] as! String
        timestamp = snapshotValue["timestamp"] as! String
        completed = false
    }
    
    func toAnyObject() -> Any {
        return [
            "audio": audio,
            "clientAudio": clientAudio,
            "message": message,
            "picture": picture,
            "timestamp": timestamp
        ]
    }
    
}
