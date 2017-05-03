//
//  DeviceListTableController.swift
//  SmartHome
//
//  Created by Jian Tian on 4/30/17.
//  Copyright © 2017 Jian Tian. All rights reserved.
//

import UIKit
import SwiftyJSON
import FirebaseDatabase

class DeviceListTableViewController: UITableViewController {
    
    // MARK: Constants
    let ref = FIRDatabase.database().reference()
    static let shared = DeviceListTableViewController()//UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceListTableViewController")
    
    // MARK: Properties
    var notificationMap = [String: [Notification]]()
    var localNotificationMap = [String: [Notification]]()
    var items: [String] = []
    var user: User!
    var userCountBarButtonItem: UIBarButtonItem!
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items.append("deviceTest")
        localNotificationMap["deviceTest"] = [Notification]()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        
        //default login user
        user = User(uid: "DoNyvln4f9dV22p3U4OMOlbWGKA3", email: "test@gmail.com")
        
        //parse json result
        ref.observe(.value, with: { snapshot in
            let result = JSON(snapshot.value!)
            print("Get data from firebase")
            for (key, value) in result {
                let index = JSON(value[1])
                self.notificationMap[key] = []
                //add current notification to map
                if (index["current"].exists()) {
                    let current = JSON(index["current"])
                    let input = self.saveDataToNotificationMap(key: key, current: current, completed: false)
                    if self.localNotificationMap[key] != nil {
                        self.localNotificationMap[key]?.append(input)
                    }
                }
                //add history notification to map
                if (index["history"].exists()) {
                    let history = JSON(index["history"])
                    for (keyHistory, valueHistory) in history {
                        let currentHistory = JSON(valueHistory)
                        var input = self.saveDataToNotificationMap(key: key, current: currentHistory, timestamp: keyHistory, completed: true)
                        if self.localNotificationMap[key] != nil {
                            self.localNotificationMap[key]?.append(input)
                        }
                    }
                }
                
            }
            
            self.tableView.reloadData()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    // MARK: UITableView Delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let deviceItem = items[indexPath.row]
        
        cell.textLabel?.text = deviceItem
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        var deviceItem = items[indexPath.row]
        
        tableView.reloadData()
    }
    
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
//            cell.detailTextLabel?.textColor = UIColor.black
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.gray
//            cell.detailTextLabel?.textColor = UIColor.gray
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "notificationSegue" {

            //update table in NotificationList
            let indexPath : NSIndexPath = self.tableView.indexPathForSelectedRow! as NSIndexPath
            let DestViewController = segue.destination as! NotificationTableViewController
            let deviceKey = items[indexPath.row]
            let localNotificationMapTwo = localNotificationMap
            let notificationArrayTwo = localNotificationMapTwo[deviceKey]
            DestViewController.notificationArray = notificationArrayTwo!
            
        } else if segue.identifier == "scanSegue" {
            
            //update notificationMap in QRSanner
            let DestViewControllerTwo = segue.destination as! QRScannerController
            let notificationMapTwo = notificationMap
            let localNotificationMapTwo = localNotificationMap
            let itemsTwo = items
            DestViewControllerTwo.notificationMap = notificationMapTwo
            DestViewControllerTwo.localNotificationMap = localNotificationMapTwo
            DestViewControllerTwo.items = itemsTwo
            
        }
        
    }
    
    func saveDataToNotificationMap(key: String, current: JSON, completed: Bool) -> Notification {
        var audio: String = ""
        var clientAudio: String = ""
        var picture: String = ""
        var message: String = ""
        var timestamp: String = ""
        
        if (current["audio"].exists()) {
            audio = current["audio"].stringValue
        }
        if (current["clientAudio"].exists()) {
            clientAudio = current["clientAudio"].stringValue
        }
        if (current["picture"].exists()) {
            picture = current["picture"].stringValue
        }
        if (current["message"].exists()) {
            message = current["message"].stringValue
        }
        if (current["timestamp"].exists()) {
            timestamp = current["timestamp"].stringValue
        }
        
        let notification = Notification(audio: audio, clientAudio: clientAudio, message: message, picture: picture, timestamp: timestamp, completed: completed, key: key)

        if self.notificationMap[key] != nil {
            self.notificationMap[key]?.append(notification)
        } else {
            self.notificationMap[key] = [notification]
        }
        return notification
    }
    
    func saveDataToNotificationMap(key: String, current: JSON, timestamp: String, completed: Bool) -> Notification {
        var audio: String = ""
        var clientAudio: String = ""
        var picture: String = ""
        var message: String = ""
        var timestamp: String = timestamp
        
        if (current["audio"].exists()) {
            audio = current["audio"].stringValue
        }
        if (current["clientAudio"].exists()) {
            clientAudio = current["clientAudio"].stringValue
        }
        if (current["picture"].exists()) {
            picture = current["picture"].stringValue
        }
        if (current["message"].exists()) {
            message = current["message"].stringValue
        }
        
        let notification = Notification(audio: audio, clientAudio: clientAudio, message: message, picture: picture, timestamp: timestamp, completed: completed, key: key)
        
        if self.notificationMap[key] != nil {
            self.notificationMap[key]?.append(notification)
        } else {
            self.notificationMap[key] = [notification]
        }
        return notification
    }

}
