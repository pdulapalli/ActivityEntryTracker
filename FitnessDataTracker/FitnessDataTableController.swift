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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(DataTableViewCell.self, forCellReuseIdentifier: "DataTableViewCell")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
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
            guard let indexPath = tableView.indexPathForSelectedRow else {
                print("Poopies")
                return
            }
            
            let dataItem = fetchedResultsController.object(at: indexPath)
            (segue.destination as! DataEntryView).fitDataItem = dataItem
        }
    }
    
    @objc func appBecomingInactive(_ notification: Notification) {
        userAuthenticationApproved = false
        appWasInBackground = true
    }
    
    @IBAction func addNewDataItem(_ sender: AnyObject) {
        guard let entityName = fetchedResultsController.fetchRequest.entity?.name else {
            return
        }
        
        let mgdContext = fetchedResultsController.managedObjectContext
        let fitnessDataItem = NSEntityDescription.insertNewObject(forEntityName: entityName, into: mgdContext) as! FitnessDataItemMgdObj
        fitnessDataItem.username = username!
        
        do {
            try mgdContext.save()
        } catch let error {
            print("Unable to add item: \(error)")
        }
    }
    
    // MARK: Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController<FitnessDataItemMgdObj> = {
        let fetchRequest = FitnessDataItemMgdObj.fetchRequest() as! NSFetchRequest<FitnessDataItemMgdObj>
        fetchRequest.fetchBatchSize = 5
        
        let sortDescriptor = NSSortDescriptor(key: "username", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error {
            print("Error with fetch operation: \(error)")
        }

        return fetchedResultsController
    }()
}

// MARK: Fetched Results Controller Delegate

extension FitnessDataTableController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            switch type {
                case .insert:
                    tableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.fade)
                case .delete:
                    tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
                case .update: // have to populate with "snippet" of fitness data item
                    guard let currentCell = tableView.cellForRow(at: indexPath!), let currentDataItem = anObject as? FitnessDataItemMgdObj else {
                        return
                    }
                    populateTableViewCellWithSnippet(cell: currentCell, with: currentDataItem)
                case .move:
                    tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
                    tableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.fade)
            }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if type == NSFetchedResultsChangeType.insert {
            tableView.insertSections([sectionIndex], with: UITableViewRowAnimation.fade)
        } else if type == NSFetchedResultsChangeType.delete {
            tableView.deleteSections([sectionIndex], with: UITableViewRowAnimation.fade)
        } else {
            return
        }
    }
}

// MARK: Necessary TableView Controller Functions

extension FitnessDataTableController {
    // Side note-- using "self" just to clarify that fetchedResultsController is in the primary class, whereas this is an extension of thet class. Can use fetchedResultsController without specifiying self, however
    
    func populateTableViewCellWithSnippet(cell: UITableViewCell, with snippet: FitnessDataItemMgdObj) {
        cell.textLabel!.text = "cows"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataCell = tableView.dequeueReusableCell(withIdentifier: "DataTableViewCell", for: indexPath) as UITableViewCell
        let dataItem = self.fetchedResultsController.object(at: indexPath)
        populateTableViewCellWithSnippet(cell: dataCell, with: dataItem)
        
        return dataCell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { // TODO: should be changed to always True/editable?
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let mgdContext = self.fetchedResultsController.managedObjectContext
            mgdContext.delete(self.fetchedResultsController.object(at: indexPath))
            
            do {
                try mgdContext.save()
            } catch let errorB as NSError {
                print("Error editing tableView\(errorB)")
                abort()
            }
        }
    }
}
