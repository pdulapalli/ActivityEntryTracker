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
                self.present(alertView, animated: true, completion: nil)
                
                return
        }
        // Remove keyboards
//        usernameField.resignFirstResponder()
//        passwordField.resignFirstResponder()
        
        if sender == registerButton { // Creating new account
            do {
                let passwordItemToAdd = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: uField, accessGroup: KeychainConfiguration.accessGroup)
                
                if try KeychainPasswordItem.passwordItems(forService: KeychainConfiguration.serviceName, accessGroup: KeychainConfiguration.accessGroup).contains(where: {$0.account == passwordItemToAdd.account}) {
                    let existingAccountAlert = UIAlertController(title: "User already exists", message: "There is already an existing user with this account", preferredStyle: .alert)
                    existingAccountAlert.addAction(UIAlertAction(title: "Got It", style: .default, handler: nil))
                    self.present(existingAccountAlert, animated: true, completion: nil)
                } else {
                    try passwordItemToAdd.savePassword(pField)
                    // MARK
                    
                    var dontClose = true
                    let registerSuccessAlert = UIAlertController(title: "Successfully Registered!", message: "Welcome \(uField)", preferredStyle: .alert)
                    registerSuccessAlert.addAction(UIAlertAction(title: "Yay!", style: .default, handler:{ (action:UIAlertAction!) -> Void in
                        dontClose = false
                        print("BLAHBLAHBLAH")
                    }))
                    print("Test \(dontClose)")
                    self.present(registerSuccessAlert, animated: true, completion: {print("Present \(dontClose)")})
                    print("Ok \(dontClose)")
                    performSegue(withIdentifier: "doneWithLogin", sender: self)
                }
                
            } catch {
                fatalError("Error adding entry to Keychain - \(error)")
            }
        } else if sender == loginButton { // Accessing existing account
            if verifyLoginCredentials(username: uField, password: pField) {
                let loginSuccessAlert = UIAlertController(title: "Welcome Back!", message: "Nice to see you again, \(uField)", preferredStyle: .alert)
                loginSuccessAlert.addAction(UIAlertAction(title: "Let's Go", style: .default, handler: nil))
                self.present(loginSuccessAlert, animated: true, completion: nil)
                performSegue(withIdentifier: "doneWithLogin", sender: self)
            } else {
                let wrongCredentialsAlert = UIAlertController(title: "Incorrect username or password", message: "Please check whether username and password are entered correctly", preferredStyle: .alert)
                wrongCredentialsAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(wrongCredentialsAlert, animated: true, completion: nil)
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
    
    @IBAction func loginTextFieldBeganEditing(_ sender: UITextField) {
        if (sender == usernameField || sender == passwordField) {
            sender.becomeFirstResponder()
        }
    }
    
    @IBAction func loginTextFieldHaltedEditing(_ sender: UITextField) {
        if (sender == usernameField || sender == passwordField) {
            sender.resignFirstResponder()
        }
    }
}
