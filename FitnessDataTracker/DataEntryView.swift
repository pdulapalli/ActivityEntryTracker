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
            do {
                populateDataItemFields(dataItem: fdItem)
                try fdItem.managedObjectContext!.save()
            } catch {
                print("Unable to save fitness data entry to records")
            }
            let registerSuccessAlert = UIAlertController(title: "Success!", message: "Your changes have been saved", preferredStyle: .alert)
            registerSuccessAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(registerSuccessAlert, animated: true, completion: nil)
        }
    }
    
    func populateDataItemFields(dataItem: FitnessDataItemMgdObj) {
        dataItem.entryDate = entryDatePicker.date
        dataItem.activityType = activityTypeTextField.hasText ? activityTypeTextField.text : dataItem.activityType
        
        // TODO: compute duration in minutes
        print("DURATION: \(durationPicker.countDownDuration)")
        dataItem.comments = commentsTextField.hasText ? commentsTextField.text : dataItem.comments
        dataItem.intensity = intensityValue != nil ? intensityValue! : dataItem.intensity
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = NSLocale.current
        formatter.dateFormat = "yyyy-MM-dd, HH:mm"
        return formatter
    }()
}

