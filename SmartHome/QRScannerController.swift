//
//  QRScannerController.swift
//  SmartHome
//
//  Created by Jian Tian on 5/1/17.
//  Copyright © 2017 Jian Tian. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseDatabase

class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    
    let ref = FIRDatabase.database().reference()
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var topbar: UIView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var notificationMap = [String: [Notification]]()
    var localNotificationMap = [String: [Notification]]()
    var items: [String] = []
    var key: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            
            // Start video capture.
            captureSession?.startRunning()
            
            // Move the message label and top bar to the front
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: topbar)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                key = metadataObj.stringValue
                self.captureSession?.stopRunning()
                
                messageLabel.text = key
                
                if notificationMap[self.key!] != nil {
                    print(self.key! + " found")
                } else {
                    print(self.key! + " not found and add to firebase")
                    let deviceItem = DeviceItem(key: key!)
                    let deviceItemRef = self.ref.child((key?.lowercased())!)
                    deviceItemRef.setValue(deviceItem.toAnyObject())
                }
                
                if localNotificationMap[self.key!] != nil {
                    
                } else {
                    self.localNotificationMap[self.key!] = [Notification(key: self.key!)]
                    if items.contains(self.key!) {
                    
                    } else {
                        items.append(self.key!)
                    }
                }
                
            }
        }
    }
    
    @IBAction func saveButtonDidTouch(_ sender: AnyObject) {
        self.captureSession?.stopRunning()
        
        dismiss(animated: true)
    }

        
    @IBAction func cancelButtonDidTouch(_ sender: AnyObject) {
        self.captureSession?.stopRunning()
        dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let destinationNavigationController = segue.destination as! UINavigationController
        let DestViewController = destinationNavigationController.topViewController as! DeviceListTableViewController
        
        let localNotificationMapTwo = localNotificationMap
        let itemsTwo = items
        
        DestViewController.localNotificationMap = localNotificationMapTwo
        DestViewController.items = itemsTwo
        
    }
    
    
}

