//
//  MainDataViewController.swift
//  FitnessDataTracker
//
//  Created by Anurag Dulapalli on 10/26/17.
//  Copyright © 2017 Anurag Dulapalli. All rights reserved.
//

import UIKit
import CoreData

class FitnessDataOverviewController: UITableViewController {
    var userAuthenticationApproved: Bool? = false
    var appWasInBackground = false
    var managedObjectContext: NSManagedObjectContext!
    
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Introduce rules for new UICollectionViewCell parameters */
        
        //let addItemButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewDataItem(_:)))
//        navigationItem.leftBarButtonItem = addItemButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive(_:)), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomingInactive(_:)), name: .UIApplicationWillResignActive, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        print("ViewDidAppear: \(userAuthenticationApproved!)")
        if let credentialsApproved = userAuthenticationApproved, !credentialsApproved {
            openLoginScreen()
        }
    }
    
    @objc func appBecameActive(_ notification: Notification) {
        if appWasInBackground {
            openLoginScreen()
        }
    }
    
    @objc func appBecomingInactive(_ notification: Notification) {
        userAuthenticationApproved = false
        appWasInBackground = true
    }
    
    @IBAction func addNewDataItem(_ sender: AnyObject) {
        print("Hello world")
        performSegue(withIdentifier: "Add Data Entry", sender: self)
//        return
    }
    
}
