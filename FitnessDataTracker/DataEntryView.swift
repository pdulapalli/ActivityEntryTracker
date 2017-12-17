//
//  DataEntryView.swift
//  FitnessDataTracker
//
//  Created by Anurag Dulapalli on 11/21/17.
//  Copyright © 2017 Anurag Dulapalli. All rights reserved.
//

import UIKit
import CoreData

class DataEntryView: UIViewController {
    @IBOutlet weak var activityTypeTextField: UITextField!
    @IBOutlet weak var entryDatePicker: UIDatePicker!
    @IBOutlet weak var durationPicker: UIDatePicker!
    @IBOutlet weak var commentsTextField: UITextField!
    @IBOutlet weak var intensityLabel: UILabel!
    
    let cancelButtonTag = 2
    let saveButtonTag = 3
    var intensityValue: Float?
    
    var fitDataItem: FitnessDataItemMgdObj?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard fitDataItem != nil else {
            return
        }
    }

    @IBAction func intensityValueChanged(_ sender: UISlider) {
        intensityLabel.text = String(format: "Intensity: %.2f", sender.value)
        intensityValue = sender.value
    }
    
    @IBAction func saveDataEntryObject(_ sender: AnyObject) {
        if sender.tag == saveButtonTag, let fdItem = fitDataItem {
            if let activityText = activityTypeTextField.text, !activityText.isEmpty {
                do {
                    try fdItem.managedObjectContext?.save()
                } catch {
                    print("Unable to save fitness data entry to records")
                }
            }
        }
        performSegue(withIdentifier: "editingEntryFinished", sender: self)
    }

}

