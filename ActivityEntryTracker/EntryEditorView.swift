//
//  DataEntryView.swift
//  ActivityEntryTracker
//
//  Created by Anurag Dulapalli on 11/21/17.
//  Copyright © 2017 Anurag Dulapalli. All rights reserved.
//

import UIKit
import CoreData

class EntryEditorView: UIViewController {
    @IBOutlet weak var activityTypeTextField: UITextField!
    @IBOutlet weak var entryDatePicker: UIDatePicker!
    @IBOutlet weak var durationPicker: UIDatePicker!
    @IBOutlet weak var commentsTextField: UITextField!
    @IBOutlet weak var intensityLabel: UILabel!
    
    let saveButtonTag = 3
    var intensityValue: Float?
    
    var activityEntryItem: ActivityEntryItemMgdObj?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard activityEntryItem != nil else {
            return
        }
        populateDataEntryFields(dataItem: activityEntryItem!)
    }
    
    @IBAction func intensityValueChanged(_ sender: UISlider) {
        updateIntensityValue(newIntensityValue: sender.value)
    }
    
    func updateIntensityValue(newIntensityValue: Float) {
        intensityLabel.text = String(format: "Intensity: %.2f", newIntensityValue)
        intensityValue = newIntensityValue
    }
    
    @IBAction func saveDataEntryObject(_ sender: AnyObject) {
        print("HI!")
        if sender.tag == saveButtonTag, let fdItem = activityEntryItem {
            do {
                updateDataItemProperties(dataItem: fdItem)
                try fdItem.managedObjectContext!.save()
            } catch {
                print("Unable to save modified entry to records")
            }
            let registerSuccessAlert = UIAlertController(title: "Success!", message: "Your changes have been saved", preferredStyle: .alert)
            registerSuccessAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(registerSuccessAlert, animated: true, completion: nil)
        }
    }
    
    func populateDataEntryFields(dataItem: ActivityEntryItemMgdObj) {
        entryDatePicker.setDate(dataItem.entryDate != nil ? dataItem.entryDate! : Date(), animated: true)
        durationPicker.setDate(durationFormatter.date(from: (String(format: "%02d", dataItem.durationMinutes / 60) + ":" + String(format: "%02d", dataItem.durationMinutes % 60)))!, animated: true)
        activityTypeTextField.text = dataItem.activityType != nil ? dataItem.activityType! : ""
        commentsTextField.text = dataItem.comments != nil ? dataItem.comments! : ""
        updateIntensityValue(newIntensityValue: dataItem.intensity)
    }
    
    func updateDataItemProperties(dataItem: ActivityEntryItemMgdObj) {
        dataItem.entryDate = entryDatePicker.date
        dataItem.activityType = activityTypeTextField.hasText ? activityTypeTextField.text : dataItem.activityType
        dataItem.comments = commentsTextField.hasText ? commentsTextField.text : dataItem.comments
        dataItem.intensity = intensityValue != nil ? intensityValue! : dataItem.intensity
        
        // Compute duration in minutes
        let subst = durationFormatter.string(from: durationPicker.date)
        let hoursFieldNum: Int64 = Int64(subst[subst.startIndex..<subst.index(of: ":")!])!
        let minutesFieldNum: Int64 = Int64(subst[subst.index(after: subst.index(of: ":")!)..<subst.endIndex])!
        dataItem.durationMinutes = hoursFieldNum * 60 + minutesFieldNum
    }
    
    let durationFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = NSLocale.current
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

