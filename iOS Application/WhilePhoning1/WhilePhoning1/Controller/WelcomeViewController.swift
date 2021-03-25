//
//  ViewController.swift
//  WhilePhoning1
//
//  Created by Alemayoh Tsige Tadesse on 2018/11/03.
//  Copyright © 2018 robins. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    //var whichButtonSelected:Int=0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    @IBAction func typeOfOperationPressed(_ sender: UIButton) {
        switch sender.tag{
            case 0:
                performSegue(withIdentifier: "toDevicemotionGraphicalView", sender: self)
            case 1:
                performSegue(withIdentifier: "toFilingAndStreaming", sender: self)
            case 2:
                performSegue(withIdentifier: "toMachineLearningClassifier", sender: self)
            default:
                return
        }
    }
    
    
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toSensorGraphicalView" {
//            let destinationVC = segue.destination as! GraphicalSensorDataViewController
//            destinationVC.tagHolder = whichButtonSelected
//          //  print(" Tag Holder = \(destinationVC.tagHolder)")
//
//        }
//    }

