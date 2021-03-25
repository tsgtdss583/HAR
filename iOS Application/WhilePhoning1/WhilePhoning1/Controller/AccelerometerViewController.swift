//
//  AccelerometerViewController.swift
//  WhilePhoning1
//
//  Created by Alemayoh Tsige Tadesse on 2018/11/05.
//  Copyright © 2018 robins. All rights reserved.
//

import UIKit
import CoreMotion
import simd
class AccelerometerViewController: UIViewController, MotionGraphContainer {
    @IBOutlet weak var graphView: GraphView!
    
    var motionManager = CMMotionManager()
    @IBOutlet weak var updateIntervalLabel: UILabel!
    @IBOutlet weak var updateIntervalSlider: UISlider!
    
    let updateIntervalFormatter = MeasurementFormatter()
    @IBOutlet var valueLabels: [UILabel]!
    
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
        //guard let motionManager = motionManager, motionManager.isAccelerometerAvailable else { return }
        
        updateIntervalLabel.text = formattedUpdateInterval
        
        motionManager.accelerometerUpdateInterval = TimeInterval(updateIntervalSlider.value)
        motionManager.showsDeviceMovementDisplay = true
        
        motionManager.startAccelerometerUpdates(to: .main) { accelerometerData, error in
            guard let accelerometerData = accelerometerData else { return }
            
            let acceleration: double3 = [accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z]
            self.graphView.add(acceleration)
            self.setValueLabels(xyz: acceleration)
        }
    }
    
    func stopUpdates() {
      //  guard let motionManager = motionManager, motionManager.isAccelerometerAvailable else { return }
        
        motionManager.stopAccelerometerUpdates()
    }

}
