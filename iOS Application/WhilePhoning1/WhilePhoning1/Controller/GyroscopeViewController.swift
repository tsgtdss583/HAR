//
//  GyroscopeViewController.swift
//  WhilePhoning1
//
//  Created by Alemayoh Tsige Tadesse on 2018/11/05.
//  Copyright © 2018 robins. All rights reserved.
//

import UIKit
import CoreMotion
import simd
class GyroscopeViewController: UIViewController, MotionGraphContainer {

    @IBOutlet weak var graphView: GraphView!
    
    var motionManager = CMMotionManager()
    
    @IBOutlet weak var updateIntervalLabel: UILabel!
    @IBOutlet weak var updateIntervalSlider: UISlider!
    
    let updateIntervalFormatter = MeasurementFormatter()
    
    @IBOutlet var valueLabels: [UILabel]!
    
    // MARK:- STOPPING THE SENSOR UPDATES
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startUpdates()
    }
    // MARK:- STOPPING THE SENSOR UPDATES
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopUpdates()
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
    
    //MARK:- SLIDER UPDATES ACTION
    @IBAction func intervalSliderChanged(_ sender: UISlider) {
        startUpdates()
    }
    
    func startUpdates() {
        //guard let motionManager = motionManager, motionManager.isGyroAvailable else { return }
        
        updateIntervalLabel.text = formattedUpdateInterval
        
        motionManager.gyroUpdateInterval = TimeInterval(updateIntervalSlider.value)
        motionManager.showsDeviceMovementDisplay = true
        
        motionManager.startGyroUpdates(to: .main) { gyroData, error in
            guard let gyroData = gyroData else { return }
            
            let rotationRate: double3 = [gyroData.rotationRate.x, gyroData.rotationRate.y, gyroData.rotationRate.z]
            self.graphView.add(rotationRate)
            self.setValueLabels(xyz: rotationRate)
        }
    }
    
    func stopUpdates() {
        //guard let motionManager = motionManager, motionManager.isAccelerometerAvailable else { return }
        
        motionManager.stopGyroUpdates()
    }
    
}
