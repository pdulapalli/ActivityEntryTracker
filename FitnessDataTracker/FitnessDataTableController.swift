//
//  MainDataViewController.swift
//  FitnessDataTracker
//
//  Created by Anurag Dulapalli on 10/26/17.
//  Copyright © 2017 Anurag Dulapalli. All rights reserved.
//

import UIKit
import CoreData

class FitnessDataTableController: UITableViewController {
    var username: String?
    var userAuthenticationApproved: Bool? = false
    var appWasInBackground = false
    var managedObjectContext: NSManagedObjectContext!
    var fitnessDataItems: [NSManagedObject] = []
    var stringarray: [String] = []
    
    enum userIdentityError : String, Error {
        case noValidUsername = "User does not have a valid username"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(DataTableViewCell.self, forCellReuseIdentifier: "DataCell")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        managedObjectContext = appDelegate.persistentContainer.viewContext
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive(_:)), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomingInactive(_:)), name: .UIApplicationWillResignActive, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("ViewDidAppear: \(userAuthenticationApproved!)")
        if let credentialsApproved = userAuthenticationApproved, !credentialsApproved {
            openLoginScreen()
        }
    }
    
    func openLoginScreen() {
        if let credentialsApproved = userAuthenticationApproved {
            print(credentialsApproved)
            performSegue(withIdentifier: "openLogin", sender: self)
        }
    }
    
    @IBAction func loginCompletedSegue(_ sender: UIStoryboardSegue) {
        userAuthenticationApproved = true // Only return from login screen if successful login
        print("Logged In")
    }
    
    @IBAction func triggerLogout(_ sender: AnyObject) {
        userAuthenticationApproved = false
        openLoginScreen()
    }
    
    @objc func appBecameActive(_ notification: Notification) {
        if appWasInBackground {
            openLoginScreen()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDataEntry" {
            print("Moo")
        }
    }
    
    @objc func appBecomingInactive(_ notification: Notification) {
        userAuthenticationApproved = false
        appWasInBackground = true
    }
    
    @IBAction func addNewDataItem(_ sender: AnyObject) {
        let fdiEntity = NSEntityDescription.entity(forEntityName: "FitnessDataItem", in: managedObjectContext)
        let fitnessDataItem = NSManagedObject(entity: fdiEntity!, insertInto: managedObjectContext)
        
        do {
            guard username != nil else {
                throw userIdentityError.noValidUsername
            }
            fitnessDataItem.setValue(username!, forKey: "username")
            fitnessDataItem.setValue("Blahblah", forKey: "activityType")
            try managedObjectContext.save()
            fitnessDataItems.append(fitnessDataItem)
        } catch is userIdentityError {
            print("Current user does not have valid user name")
            let usernameAlert = UIAlertController(title: "Invalid username alert", message: "Returning to login screen", preferredStyle: .alert)
            usernameAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action:UIAlertAction!) -> Void in
                self.openLoginScreen()
            }))
            self.present(usernameAlert, animated: true, completion: nil)
        } catch let error as NSError {
            print("Unable to add item \(error)")
        }
        tableView.reloadData()
    }
    
    @IBAction func finishedDataEntrySegue(_ sender: UIStoryboardSegue) {
        print("Came back!")
        // TODO: include mechanism to persist data b/w Entry view and table view
    }
    
    // MARK: Necessary TableView Controller Functions
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fitnessDataItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataCell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath)
//        dataCell.textLabel?.text = (fitnessDataItems[indexPath.row].value(forKey: "username") as? String) +
        
        return dataCell
    }
}

// MARK: Fetched Results Controller

extension FitnessDataTableController: NSFetchedResultsControllerDelegate {
    
}

