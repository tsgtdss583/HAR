//
//  MachineLearningViewController.swift
//  WhilePhoning1
//
//  Created by Alemayoh Tsige Tadesse on 2019/02/11.
//  Copyright © 2019 robins. All rights reserved.
//

import Foundation
import Dispatch
import UIKit
import CoreMotion
import CoreML

class MachineLearningViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{
    let MLResultsTableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.backgroundColor = UIColor.lightGray
        return t
    }()
    //let activityies = ["Walking...","Jumping..","UpStairs...","DownStarirs...","Running...","Bike Riding...","Still...","Lying..."]
    var displayArray : [ClassificationResults] = [ClassificationResults]()
    var updateTimer=Timer()
    let MLmotionmanager=CMMotionManager()
    var accX = [1.0]
    var accY = [1.0]
    var accZ = [1.0]
    var gyroX = [1.0]
    var gyroY = [1.0]
    var gyroZ = [1.0]
    let zeroPad = Array(repeating: 0.0, count: 60)
    var timeInterval = 0.02
    var dataLength = 0
    let MLqueue=OperationQueue()
    let activityClassifierModel = MLModelKeras15_revised()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // add the table view to self.view
        self.view.addSubview(MLResultsTableView)
        MLResultsTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32.0).isActive = true
        MLResultsTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200.0).isActive = true
        MLResultsTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32.0).isActive = true
        MLResultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32.0).isActive = true
        
        // set delegate and datasource
        MLResultsTableView.delegate = self
        MLResultsTableView.dataSource = self
        
        // register a defalut cell
        MLResultsTableView.register(UINib(nibName: "ClassifierResultsTableViewCell", bundle: nil), forCellReuseIdentifier: "myCustomCell")
        configureTableCellView()
        MLResultsTableView.separatorStyle = .none
        MLResultsTableView.tableFooterView = UIView(frame: .zero)    }
    

    @IBAction func startStopButtonsPressed(_ sender: UIButton) {
        switch sender.currentTitle {
        case "Start":
            startClassificationOperation()
        default:
            stopClassification()
        }
        
    }
    func startClassificationOperation() {
        dataLength = 0
        MLmotionmanager.showsDeviceMovementDisplay = true
         if MLmotionmanager.isGyroAvailable && MLmotionmanager.isAccelerometerAvailable {
        updateTimer=Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.acceleroGyroData), userInfo: nil, repeats: true)

        }
    }
    
    @objc func acceleroGyroData() {
         MLmotionmanager.startAccelerometerUpdates(to: MLqueue){
         accSensorValues, error in
         guard let accData = accSensorValues else {return}
         self.accX.append(accData.acceleration.x)
         self.accY.append(accData.acceleration.y)
         self.accZ.append(accData.acceleration.z)
         
         }
        /*accX.append(0.0)
        accY.append(0.0)
        accZ.append(0.0)*/
        
         MLmotionmanager.startGyroUpdates(to: MLqueue){
         gyroSensorValues, error in
         guard let gyroData = gyroSensorValues else {return}
         self.gyroX.append(gyroData.rotationRate.x)
         self.gyroY.append(gyroData.rotationRate.y)
         self.gyroZ.append(gyroData.rotationRate.z)
         }
        /*gyroX.append(1.0)
        gyroY.append(1.0)
        gyroZ.append(1.0)*/
        
        //dataLength+=1
        // checkk datalength Call the MLMultiArray arranger
        /* if dataLength==60{
         print(accX.count)
         print(accY.count)
         print(gyroZ.count)
         print("============")
         inputDataPreparation()
         }*/
        if accX.count >= 61 && accY.count >= 61 && accZ.count >= 61 && gyroX.count >= 61 && gyroY.count >= 61 && gyroZ.count >= 61 {
            MLmotionmanager.stopAccelerometerUpdates()
            MLmotionmanager.stopGyroUpdates()
            print(accX.count)
            print(accY.count)
            print(accZ)
            print("============")
            inputDataPreparation()
        }
    }
    func bringTheValues(){
        
    }
    func inputDataPreparation() {
        accX.remove(at: 0)
        accY.remove(at: 0)
        accZ.remove(at: 0)
        gyroX.remove(at: 0)
        gyroY.remove(at: 0)
        gyroZ.remove(at: 0)
        
        guard let multiArrayInput = try? MLMultiArray(shape: [1,15,60], dataType: .double) else {
            fatalError(" Error while creating MLMultiArray variable")
        }

        for i in 0...59 {
            //print(i)
            bringTheValues()
            multiArrayInput[i] = NSNumber(floatLiteral: accX[i])
            multiArrayInput[i+60]=NSNumber(floatLiteral: accY[i])
            multiArrayInput[i+2*60]=NSNumber(floatLiteral: accZ[i])
            multiArrayInput[i+3*60]=NSNumber(floatLiteral: accX[i])
            multiArrayInput[i+4*60]=NSNumber(floatLiteral: accY[i])
            multiArrayInput[i+5*60]=NSNumber(floatLiteral: accZ[i])
            multiArrayInput[i+6*60]=NSNumber(floatLiteral: accX[i])
            multiArrayInput[i+7*60]=NSNumber(floatLiteral: zeroPad[i])
            multiArrayInput[i+8*60]=NSNumber(floatLiteral: gyroX[i])
            multiArrayInput[i+9*60]=NSNumber(floatLiteral: gyroY[i])
            multiArrayInput[i+10*60]=NSNumber(floatLiteral: gyroZ[i])
            multiArrayInput[i+11*60]=NSNumber(floatLiteral: gyroX[i])
            multiArrayInput[i+12*60]=NSNumber(floatLiteral: gyroY[i])
            multiArrayInput[i+13*60]=NSNumber(floatLiteral: gyroZ[i])
            multiArrayInput[i+14*60]=NSNumber(floatLiteral: gyroX[i])

        }
        //call MLClassifier
        accX = [1.0]
        accY = [1.0]
        accZ = [1.0]
        gyroX = [1.0]
        gyroY = [1.0]
        gyroZ = [1.0]
        dataLength = 0
        MLClassificationandUIUpdate(inputData: multiArrayInput)
        
    
    }
    func MLClassificationandUIUpdate(inputData:MLMultiArray) {
        guard let predictionResults = try? activityClassifierModel.prediction(sensorDataInput: inputData) else {fatalError("Error in MLModel during predeiction")}
        let displayResults = ClassificationResults()
        displayResults.predictedActivty = predictionResults.classLabel
       
        
        displayResults.predictedActivityConfidenceLevel = predictionResults.output1[displayResults.predictedActivty]!
        displayArray.append(displayResults)
        configureTableCellView()
        MLResultsTableView.reloadData()
        let index = IndexPath(row: displayArray.count-1, section: 0)
        MLResultsTableView.scrollToRow(at: index, at: .none, animated: false)
        //for j in 0...inputData.count {
          //  print(inputData[j])
        //}
        
    }
    func stopClassification(){
        updateTimer.invalidate()
        MLmotionmanager.stopAccelerometerUpdates()
        MLmotionmanager.stopGyroUpdates()
        
    }
    func numberOfSections(in MLResultsTableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCustomCell", for: indexPath) as! ClassifierResultsTableViewCell
        cell.predictedActivtyDisplayLabel.text = displayArray[indexPath.row].predictedActivty
        cell.confidenceLevelDisplayLabel.text = String(displayArray[indexPath.row].predictedActivityConfidenceLevel)
        
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Activty                          Confidence"
        default:
            return ""
        }
        
    }
    func configureTableCellView () {
        MLResultsTableView.rowHeight = UITableView.automaticDimension
        MLResultsTableView.estimatedRowHeight = 120.0
    }

}
