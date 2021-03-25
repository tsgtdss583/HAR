//
//  MagnetometerViewController.swift
//  WhilePhoning1
//
//  Created by Alemayoh Tsige Tadesse on 2018/11/05.
//  Copyright © 2018 robins. All rights reserved.
//

import UIKit
import CoreMotion
import simd
class MagnetometerViewController: UIViewController, MotionGraphContainer{

    @IBOutlet weak var graphView: GraphView!
    
     var motionManager = CMMotionManager()
    
    @IBOutlet weak var updateIntervalLabel: UILabel!
    @IBOutlet weak var updateIntervalSlider: UISlider!
    
    let updateIntervalFormatter = MeasurementFormatter()
    
    @IBOutlet var valueLabels: [UILabel]!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        graphView.valueRanges = [-30.0...30.0, -250.0...250.0, -1000.0...1000.0]
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startUpdates()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopUpdates()
    }
    
    @IBAction func intervalSliderChanged(_ sender: UISlider) {
        startUpdates()
    }
    
    func startUpdates() {
        //guard let motionManager = motionManager, motionManager.isGyroAvailable else { return }
        
        updateIntervalLabel.text = formattedUpdateInterval
        
        motionManager.magnetometerUpdateInterval = TimeInterval(updateIntervalSlider.value)
        motionManager.showsDeviceMovementDisplay = true
        
        motionManager.startMagnetometerUpdates(to: .main) { magnetometerData, error in
            guard let magnetometerData = magnetometerData else { return }
            
            let magneticField: double3 = [magnetometerData.magneticField.x, magnetometerData.magneticField.y, magnetometerData.magneticField.z]
            self.graphView.add(magneticField)
            self.setValueLabels(xyz: magneticField)
        }
    }
    
    func stopUpdates() {
       // guard let motionManager = motionManager, motionManager.isAccelerometerAvailable else { return }
        
        motionManager.stopMagnetometerUpdates()
    }

}
