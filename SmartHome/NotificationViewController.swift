//
//  NotificationViewController.swift
//  SmartHome
//
//  Created by Jian Tian on 5/1/17.
//  Copyright © 2017 Jian Tian. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseDatabase


class NotificationViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITextFieldDelegate {
    
    // MARK: Constants
    let notificationCell = "NotificationCell"
    let ref = FIRDatabase.database().reference()
    
    // MARK: Properties
    weak var delegate: NotificationTableViewController!
    var currentNotification: Notification!
    var audioPlayer: AVAudioPlayer!
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet weak var messageTextField: UITextField!

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var responseButton: UIButton!
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //text
        messageTextField.delegate = self
        //audio
        self.prepareAudioRecorder()
        //output
        showContent()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //text input for message
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentNotification.message = textField.text!
    }
    
    //sign out
    @IBAction func signoutButtonPressed(_ sender: Any) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginView") as! LoginViewController
        self.present(loginVC, animated: true, completion: nil)
    }
    
    //play audio
    @IBAction func playButtonClick(_ sender: UIButton) {
        if playButton.titleLabel?.text == "PLAY" {
            playButton.setTitle("STOP", for: .normal)
            
            prepareAudioPlayer()
            audioPlayer.play()
        } else {
            audioPlayer.stop()
            playButton.setTitle("PLAY", for: .normal)
            
        }
    }
    
    var testEconde: String!
    func prepareAudioPlayer() {
        do {
//            let audioData = Data(base64Encoded: testEconde, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
//            if audioData != nil {
//                try audioPlayer = AVAudioPlayer(data: audioData!)
//            }
            try audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: self.audioFileLocation()))
        } catch {
            print(error)
        }
        
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        audioPlayer.volume = 10.0
    }


    
    @IBAction func recordButtonClick(_ sender: UIButton) {
        if !audioRecorder.isRecording {
            //start recording
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
            } catch {
                print(error)
            }
        } else {
            //stop
            audioRecorder.stop()
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(false)
            } catch {
                print(error)
            }
            
            let fileLocation = self.audioFileLocation()
            let plainData = fileLocation.data(using: String.Encoding.utf8)
            let clientAudio = (plainData?.base64EncodedString(options: .endLineWithLineFeed))!
            currentNotification.clientAudio = clientAudio
//            print(testEconde)
//            let fileData = NSData(contentsOfFile: fileLocation)
//            let base64String = fileData?.base64EncodedStringWithOptions(.allZeros)
            
        }
        
        self.updateRecordButtonTitle()
    }
    
    //audio input
    func prepareAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(url: URL(fileURLWithPath: self.audioFileLocation()), settings: self.audioRecorderSettings())
            audioRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
    
    func audioFileLocation() -> String {
        return NSTemporaryDirectory().appending("audioRecording.m4a")
    }
    
    func audioRecorderSettings() -> [String:Any] {
        let settings = [AVFormatIDKey: NSNumber.init(value: kAudioFormatAppleLossless), AVSampleRateKey: NSNumber.init(value: 44100),
                        AVNumberOfChannelsKey: NSNumber.init(value: 1), AVEncoderAudioQualityKey: NSNumber.init(value: AVAudioQuality.high.rawValue)]
        return settings
    }
    
    func updateRecordButtonTitle() {
        if audioRecorder.isRecording {
            recordButton.setTitle("Recording...", for: .normal)
        } else {
            recordButton.setTitle("Record", for: .normal)
        }
    }
    
//    func verifyFileExists() -> Bool {
//        let fileManager = FileManager.default
//        return FileManager.fileExists(atPath: self.audioFileLocation()) as Bool
//    }
    
    //save to firebase
    @IBAction func responseButtonClick(_ sender: Any) {
        let notificationRef = self.ref.child(currentNotification.key+"/1/current")
        
        notificationRef.updateChildValues(currentNotification.toAnyObject() as! [AnyHashable : Any])
        print ("update notification " + currentNotification.key)
        
        responseButton.isEnabled = false
        responseButton.setTitleColor(UIColor.black, for: .disabled)
        responseButton.backgroundColor = UIColor.gray
    }
    
    
    //output
    func showContent() {
        var strDate: String = ""
        if currentNotification.timestamp != nil {
            let epocTime = TimeInterval(currentNotification.timestamp)! / 1000
            let date = NSDate(timeIntervalSince1970: Double(epocTime))
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "PST") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
            strDate = dateFormatter.string(from: date as Date)
        }
        timeLabel.text = strDate
        
        let imageData = Data(base64Encoded: currentNotification.picture, options: .ignoreUnknownCharacters)!
        let imageView = UIImage(data: imageData)
        image.image = imageView
    }
    
}
