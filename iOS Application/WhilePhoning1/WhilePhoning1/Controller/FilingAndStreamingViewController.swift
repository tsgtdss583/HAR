//
//  FilingAndStreamingViewController.swift
//  WhilePhoning1
//
//  Created by Alemayoh Tsige Tadesse on 2018/11/07.
//  Copyright © 2018 robins. All rights reserved.
//
import Foundation
import Socket
import Dispatch
import UIKit
import CoreMotion
class FilingAndStreamingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var operationTypeSelector: UISegmentedControl!
    @IBOutlet weak var fileName: UITextField!
    @IBOutlet weak var samplingRateTextField: UITextField!
    @IBOutlet weak var samplingRateTypeSelector: UISegmentedControl!
    //Switchs
    @IBOutlet weak var timeStampSwitch: UISwitch!
    @IBOutlet weak var accSwitch: UISwitch!
    @IBOutlet weak var gyroSwitch: UISwitch!
    @IBOutlet weak var magnetoSwitch: UISwitch!
    @IBOutlet weak var yawSwitch: UISwitch!
    @IBOutlet weak var rollSwitch: UISwitch!
    @IBOutlet weak var pitchSwitch: UISwitch!
    
    @IBOutlet weak var ipAddressTextView: UITextView!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var portSettingSelector: UISegmentedControl!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var filesButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    // Variable declaration
    let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Sensor_data.csv")
    var timer=Timer()
    let motionmanager=CMMotionManager()
    var whcihOperation : Int {
        return operationTypeSelector.selectedSegmentIndex
    }
    // Sensor values
    var accX = 1.1000001
    var accY = 1.2000001
    var accZ = 1.3000001
    var gyroX = 2.1000001
    var gyroY = 2.2000001
    var gyroZ = 2.3000001
    var magnetoX = 3.1000001
    var magnetoY = 3.2000001
    var magnetoZ = 3.3000001
    var yaw = 4.1000001
    var roll = 4.2000001
    var pitch = 4.3000001
    // Sensor Availability
    var accAvailable = false
    var gyroAvailable = false
    var magnetoAvailable = false
    var yawAvailable = false
    var rollAvailable = false
    var pitchAvailable = false
    var timestampAvailable = false
    //
    var finalDate = "Sensor"
    var valueString = ""
    var streamValueMatrix=""
    var csvText:String = ""
    var tempValueMatrix=[String]()
    var timestamp = 0.0
    var timeInterval = 0.02
    var selectedSensor = [Int]()
    var activeTextFieldBottomCoordinate:CGFloat = 0.0
    let queue=OperationQueue()
    //Stream variables decalration
    static let bufferSize = 4096
    let port = 1337
    var listenSocket: Socket? = nil
    var continueRunning = true
    var connectedSockets = [Int32: Socket]()
    let socketLockQueue = DispatchQueue(label: "Socket Queue")
    var newSocket : Socket? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ipAddressTextView.text="Ex. 10.0.0.1"
        portTextField.text = "1337"
        fileName.delegate = self
        samplingRateTextField.delegate = self
        portTextField.delegate = self
        // Keyboard event listners
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    // De Initializing Observers
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        // Close all open sockets...
        for socket in connectedSockets.values {
            socket.close()
        }
        self.listenSocket?.close()
    }
    
    
    
    @IBAction func switchesActions(_ sender: UISwitch) {
        selectedSensor=[]
        if timeStampSwitch.isOn {
            selectedSensor.append(0)
        }
        if !timeStampSwitch.isOn {
            selectedSensor = selectedSensor.filter {$0 != 0}
        }
        if accSwitch.isOn {
            selectedSensor.append(1)
        }
        if !accSwitch.isOn {
            selectedSensor = selectedSensor.filter {$0 != 1}
        }
        if gyroSwitch.isOn {
            selectedSensor.append(2)
        }
        if !gyroSwitch.isOn {
            selectedSensor = selectedSensor.filter {$0 != 2}
        }
        if magnetoSwitch.isOn {
            selectedSensor.append(3)
        }
        if !magnetoSwitch.isOn {
            selectedSensor = selectedSensor.filter {$0 != 3}
        }
        if yawSwitch.isOn {
            selectedSensor.append(4)
        }
        if !yawSwitch.isOn {
            selectedSensor = selectedSensor.filter {$0 != 4}
        }
        if rollSwitch.isOn {
            selectedSensor.append(5)
        }
        if !rollSwitch.isOn {
            selectedSensor = selectedSensor.filter {$0 != 5}
        }
        if pitchSwitch.isOn {
            selectedSensor.append(6)
        }
        if !pitchSwitch.isOn {
            selectedSensor = selectedSensor.filter {$0 != 6}
        }
    }
    
    //MARK:- Buttons' Actions
    
    @IBAction func startButtonAction(_ sender: UIButton) {
        startUpdating()
    }
    @IBAction func stopButtonAction(_ sender: UIButton) {
        stopUpdating()
    }
    @IBAction func shareButtonAction(_ sender: UIButton) {
        sharingData()
    }
    @IBAction func fileButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "toFilesView", sender: self)
    }
    @IBAction func infoButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "toInfoView", sender: self)
    }
    
    
    //MARK:- sensorAvailability
    func sensorAvailability () {
        timestampAvailable=false
        accAvailable = false
        gyroAvailable = false
        magnetoAvailable = false
        yawAvailable = false
        rollAvailable = false
        pitchAvailable = false
        
        for i in selectedSensor {
            if i == 0 {
                csvText.append("Time_Stamp")
                if i != selectedSensor.last! {
                    csvText.append(",")
                }
                timestampAvailable=true
                
            }
            else if i == 1 {
                csvText.append("Acc_X,Acc_Y,Acc_Z")
                if i != selectedSensor.last! {
                    csvText.append(",")
                }
                accAvailable=true
            }
            else if i == 2 {
                csvText.append("Gyro_X,Gyro_Y,Gyro_Z")
                if i != selectedSensor.last! {
                    csvText.append(",")
                }
                gyroAvailable=true
            }
            else if i == 3 {
                csvText.append("Magneto_X,Magneto_Y,Magneto_Z")
                if i != selectedSensor.last! {
                    csvText.append(",")
                }
                magnetoAvailable=true
            }
            else if i == 4 {
                csvText.append("Yaw")
                if i != selectedSensor.last! {
                    csvText.append(",")
                }
                yawAvailable=true
            }
            else if i == 5 {
                csvText.append("Roll")
                if i != selectedSensor.last! {
                    csvText.append(",")
                }
                rollAvailable=true
            }
            else if i == 6 {
                csvText.append("Pitch")
                if i != selectedSensor.last! {
                    csvText.append(",")
                }
                pitchAvailable=true
            }
            
        }
        csvText.append("\n")
    }
    //MARK:- startUpdating
    func startUpdating(){
        continueRunning=true
        csvText=""
        valueString=""
        streamValueMatrix=""
        tempValueMatrix = [String]()
        sensorAvailability()
        motionmanager.showsDeviceMovementDisplay = true
        guard let timeIntervalConverted = Double(samplingRateTextField.text!) else {return }
        timeInterval = 1/timeIntervalConverted
        
        if whcihOperation == 1 {
            timer=Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.streamData), userInfo: nil, repeats: true)
        }
        else {
            
            timer=Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.savingData), userInfo: nil, repeats: true)
        }
    }
    @objc func savingData(){
        sensorUpdateValues1()
        tempValueMatrix=[tempValueMatrix.joined(separator: ",")]
        valueString.append(tempValueMatrix[0])
        valueString.append("\n")
    }
    func sensorUpdateValues1(){
        //        valueString=""
        tempValueMatrix = [String]()
        if timestampAvailable {
            
            tempValueMatrix.append("\(timestamp)")
            
        }
        if accAvailable {
            AccelerometerData()
            tempValueMatrix.append( "\(accX),\(accY),\(accZ)")
        }
        if gyroAvailable {
            GyroscopeData()
            tempValueMatrix.append( "\(gyroX),\(gyroY),\(gyroZ)")
        }
        if magnetoAvailable {
            MagnetometerData()
            tempValueMatrix.append( "\(magnetoX),\(magnetoY),\(magnetoZ)")
        }
        if yawAvailable {
            DeviceMotionData()
            tempValueMatrix.append( "\(yaw)")
        }
        if rollAvailable {
            DeviceMotionData()
            tempValueMatrix.append("\(roll)")
            
        }
        if pitchAvailable {
            DeviceMotionData()
            tempValueMatrix.append( "\(pitch)")
            
        }
        
        
        //csvText.append(contentsOf: valueString)
        
        timestamp += timeInterval
        timestamp = (timestamp*pow(10.0, 13.0)).rounded()/pow(10.0, 13.0)
    }
    @objc func sensorUpdateValues2(){
        streamValueMatrix = ""
        
        //        if accAvailable {
        AccelerometerData()
        GyroscopeData()
        streamValueMatrix.append( "\(accX),\(accY),\(accZ),\(gyroX),\(gyroY),\(gyroZ)\n")
        //        }
        //        if gyroAvailable {
        //            GyroscopeData()
        //            streamValueMatrix.append( "\(gyroX),\(gyroY),\(gyroZ)\n")
        //        }
    }
    
    //MARK:- Stream Data
    @objc func streamData(){
        let streamQueue = DispatchQueue.global(qos: .userInteractive)
        streamQueue.async { [unowned self] in
            
            do {
                // Create an IPV4 socket...
                try self.listenSocket = Socket.create(family: .inet)
                
                guard let socket = self.listenSocket else {
                    
                    print("Unable to unwrap socket...")
                    return
                }
                
                try socket.listen(on: self.port)
                
                //                print("Listening on port: \(socket.listeningPort)")
                
                repeat {
                    if self.continueRunning {
                        self.newSocket = try socket.acceptClientConnection()
                        
                        self.addNewConnection(socket: self.newSocket!)
                    }
                    else {
                        self.addNewConnection(socket: self.newSocket!)
                    }
                } while self.continueRunning
                
            }
            catch let error {
                guard error is Socket.Error else {
                    print("Unexpected error...")
                    return
                }
                
                
            }
        }
    }
    
    
    
    //MARK: ADD Connecttion for streaming
    func addNewConnection(socket: Socket) {
        
        if continueRunning {
            // Add the new socket to the list of connected sockets...
            socketLockQueue.sync { [unowned self, socket] in
                self.connectedSockets[socket.socketfd] = socket
                
            }
        }
        continueRunning=false
        // Get the global concurrent queue...
        let streamQueue = DispatchQueue.global(qos: .default)
        //
        streamValueMatrix=""
        
        streamQueue.async { [unowned self, socket] in
            do {
                
                self.sensorUpdateValues2()
                try socket.write(from: self.streamValueMatrix)
            }
            catch let error {
                guard error is Socket.Error else {
                    print("Unexpected error by connection at \(socket.remoteHostname):\(socket.remotePort)...")
                    return
                }
            }
        }
    }
    
    //MARK:- stopUpdating
    func stopUpdating(){
        timer.invalidate()
        timestamp=0.0
        csvText.append(contentsOf: valueString)
        //dateFormating()
        //        print(csvText)
        do{
            //            try csvText.write(to: path as URL, atomically: true, encoding: String.Encoding.utf8)
            try csvText.write(to: path!,atomically: true, encoding: String.Encoding.utf8)
        }
        catch {
            print("unable to create file")
        }
        
        motionmanager.stopAccelerometerUpdates()
        motionmanager.stopGyroUpdates()
        motionmanager.stopMagnetometerUpdates()
        motionmanager.startDeviceMotionUpdates()
        for socket in connectedSockets.values {
            socket.close()
        }
        
        listenSocket?.close()
    }
    //MARK:- sharingData
    func sharingData(){
        //dateFormating()
        //path.appendingPathComponent(finalDate)
        let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
        //vc.excludedActivityTypes=[UIActivitytype]
        present(vc, animated: true, completion: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        view.frame.origin.y = 0
    }
    func AccelerometerData() {
        if motionmanager.isAccelerometerAvailable{
            motionmanager.startAccelerometerUpdates(to: queue){
                accdata, error in
                guard let data = accdata else {return}
                self.accX = data.acceleration.x
                self.accY = data.acceleration.y
                self.accZ = data.acceleration.z
                
            }
            //        self.accX = 1.1
            //        self.accY = 1.2
            //        self.accZ = 1.3
        }
        
    }
    func GyroscopeData() {
        if motionmanager.isGyroAvailable{
            motionmanager.startGyroUpdates(to: queue){
                gyrodata, error in
                guard let data = gyrodata else {return}
                self.gyroX = data.rotationRate.x
                self.gyroY = data.rotationRate.y
                self.gyroZ = data.rotationRate.z
                
                
            }
            //        self.gyroX = 2.1
            //        self.gyroY = 2.2
            //        self.gyroZ = 2.3
        }
    }
    func MagnetometerData() {
        if motionmanager.isMagnetometerAvailable{
            motionmanager.startMagnetometerUpdates(to: queue){
                magnetodata, error in
                guard let data = magnetodata else {return}
                self.magnetoX = data.magneticField.x
                self.magnetoY = data.magneticField.y
                self.magnetoZ = data.magneticField.z
                
                
            }
            //        self.magnetoX = 3.1
            //        self.magnetoY = 3.2
            //        self.magnetoZ = 3.3
        }
    }
    func DeviceMotionData() {
        if motionmanager.isDeviceMotionAvailable{
            motionmanager.startDeviceMotionUpdates(to: queue){
                devicedata, error in
                guard let data = devicedata else {return}
                self.yaw = data.attitude.yaw
                self.roll = data.attitude.roll
                self.pitch = data.attitude.pitch
                
                
            }
            //        self.yaw = 4.1
            //        self.roll = 4.2
            //        self.pitch = 4.3
        }
    }
    //Date Formating
    //    func dateFormating () {
    //        let formatter = DateFormatter()
    //        formatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
    //        let myString = formatter.string(from: Date())
    //        let myDate = formatter.date(from: myString)
    //        finalDate = formatter.string(from: myDate!)
    //        path.appendingPathComponent(finalDate)
    //    }
    
    
    // Dismiss keyboard when return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //print("Enter Pressed")
        view.selectedTextField?.resignFirstResponder()
        return true
    }
    // Keyboard Notifcation Excuter
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        activeTextFieldBottomCoordinate = (view.selectedTextField?.frame.origin.y)! + (view.selectedTextField?.frame.height)!
        if (notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification) && ((activeTextFieldBottomCoordinate + keyboardRect.height - view.frame.height) > 0) {
            view.frame.origin.y = -keyboardRect.height
        }
        else {
            view.frame.origin.y = 0
        }
        
    }
    
}
// to know the active text field
extension UIView {
    var textFieldsInView: [UITextField] {
        return subviews
            .filter ({ !($0 is UITextField) })
            .reduce (( subviews.compactMap { $0 as? UITextField }), { summ, current in
                return summ + current.textFieldsInView
            })
    }
    var selectedTextField: UITextField? {
        return textFieldsInView.filter { $0.isFirstResponder }.first
    }
}
// for Dismissing the Keyboard after pressing outsid it
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
