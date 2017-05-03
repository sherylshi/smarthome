//
//  OnlineUsersTableViewController.swift
//  SmartHome
//
//  Created by Jian Tian on 4/30/17.
//  Copyright © 2017 Jian Tian. All rights reserved.
//

import UIKit

class NotificationTableViewController: UITableViewController {
    
    // MARK: Constants
    
    // MARK: Properties
    var notificationArray: [Notification] = []
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
    
    }
    
    // MARK: UITableView Delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
        let notification = notificationArray[indexPath.row]
        
        var strDate: String = ""
        if notification.timestamp != nil {
            let epocTime = TimeInterval(notification.timestamp)! / 1000
            let date = NSDate(timeIntervalSince1970: Double(epocTime))
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "PST") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
            strDate = dateFormatter.string(from: date as Date)
        }
        
        cell.textLabel?.text = "Time: " + strDate
        
        let toggledCompletion = notification.completed
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notificationArray.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        notificationArray[indexPath.row].completed = true
        var notification = notificationArray[indexPath.row]
        let toggledCompletion = !notification.completed
        
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        notification.completed = toggledCompletion
        
        tableView.reloadData()
    }
    
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.gray
        }
    }
    
    // MARK: Actions
    @IBAction func signoutButtonPressed(_ sender: Any) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginView") as! LoginViewController
        self.present(loginVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var indexPath : NSIndexPath = self.tableView.indexPathForSelectedRow! as NSIndexPath
        var DestViewController = segue.destination as! NotificationViewController
        var notificationArrayTwo : Notification
        notificationArrayTwo = notificationArray[indexPath.row]
        DestViewController.currentNotification = notificationArrayTwo
        
    }
    
}
