//
//  LoginViewController.swift
//  FitnessDataTracker
//
//  Created by Anurag Dulapalli on 10/20/17.
//  Copyright © 2017 Anurag Dulapalli. All rights reserved.
//

import UIKit
import Foundation

struct KeychainConfiguration {
    static let serviceName = "FitnessDataTracker"
    static let accessGroup: String? = nil
}

class LoginViewController: UIViewController {
    
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logUserIn(_ sender: UIButton) {
        guard let uField = usernameField.text, let pField = passwordField.text,
            !uField.isEmpty && !pField.isEmpty else {
                let alertView = UIAlertController(title: "Empty Field", message: "Left Username or Password Blank", preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(alertView, animated: true, completion: nil)
                
                return
        }
        usernameField.resignFirstResponder() // Remove keyboards
        passwordField.resignFirstResponder()
        
        if sender.tag == registerButton.tag { // Creating new account
            do {
                var passwordItemToAdd = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: uField, accessGroup: KeychainConfiguration.accessGroup)
                
                if try KeychainPasswordItem.passwordItems(forService: KeychainConfiguration.serviceName, accessGroup: KeychainConfiguration.accessGroup).contains(where: {$0.account == passwordItemToAdd.account}) {
                    let existingAccountAlert = UIAlertController(title: "User already exists", message: "There is already an existing user with this account", preferredStyle: .alert)
                    existingAccountAlert.addAction(UIAlertAction(title: "Got It", style: .default, handler: nil))
                    present(existingAccountAlert, animated: true, completion: nil)
                } else {
                    try passwordItemToAdd.savePassword(pField)
                    // TODO--Segue
                }
                
            } catch {
                fatalError("Error updating keychain - \(error)")
            }
        } else if sender.tag == loginButton.tag { // Accessing existing account
            if verifyLoginCredentials(username: uField, password: pField) {
                //TODO--Segue
            } else {
                let wrongCredentialsAlert = UIAlertController(title: "Incorrect username or password", message: "Please check whether username and password are entered correctly", preferredStyle: .alert)
                wrongCredentialsAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(wrongCredentialsAlert, animated: true, completion: nil)
            }
        }
    }
    
    func verifyLoginCredentials(username: String, password: String) -> Bool {
        do {
            if try KeychainPasswordItem.passwordItems(forService: KeychainConfiguration.serviceName, accessGroup: KeychainConfiguration.accessGroup).contains(where: {try ($0.account == username) && ($0.readPassword() == password)}) {
                return true
            }
        } catch {
            fatalError("Error accessing password via Keychain \(error)")
        }
        return false
    }
}
