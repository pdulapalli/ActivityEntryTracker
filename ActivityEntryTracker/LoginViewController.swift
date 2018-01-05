//
//  LoginViewController.swift
//  ActivityEntryTracker
//
//  Created by Anurag Dulapalli on 10/20/17.
//  Copyright © 2017 Anurag Dulapalli. All rights reserved.
//

import UIKit
import Foundation

struct KeychainConfiguration {
    static let serviceName = "ActivityEntryTracker"
    static let accessGroup: String? = nil
}

class LoginViewController: UIViewController {
    
    @IBOutlet var loginTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLoginViewElements()
    }
    
    func initializeLoginViewElements() {
        self.loginButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.loginTextField.adjustsFontSizeToFitWidth = true
        self.loginTextField.autocorrectionType = UITextAutocorrectionType.no
    }
    
    @IBAction func logUserIn(_ sender: UIButton) {
        guard let loginName: String = loginTextField.text,
            !loginName.isEmpty else {
                let alertView = UIAlertController(title: "Empty Field", message: "Left Username Blank", preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertView, animated: true, completion: nil)
                return
        }

        do {
            let isExistingUser: Bool = try checkExistingUser(loginName: loginName)
            
            let passwordInquiry = UIAlertController(title: isExistingUser ? "Password" : "Create Your Password", message: isExistingUser ? "Please enter your password" : "Please enter desired password" , preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action:UIAlertAction!) -> Void in
                guard let passwordText = passwordInquiry.textFields?[0].text else {
                    return
                }
                self.loggingUserIn(isExistingUser: isExistingUser, loginName: loginName, password: passwordText)
            })
            confirmAction.isEnabled = false
            passwordInquiry.addAction(confirmAction)
            passwordInquiry.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            passwordInquiry.addTextField(configurationHandler: { (textField: UITextField!) in
                NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using: { (_) in
                    if let textIsEmpty = textField.text?.isEmpty, !textIsEmpty {
                        confirmAction.isEnabled = true
                    } else {
                        confirmAction.isEnabled = false
                    }
                })
            })
            
            if let passwordTextField = passwordInquiry.textFields?[0] {
                passwordTextField.placeholder = "Enter password here..."
                passwordTextField.isSecureTextEntry = true
                passwordTextField.autocorrectionType = UITextAutocorrectionType.no
            }
            
            self.present(passwordInquiry, animated: true, completion: nil)
        } catch {
            fatalError("Error accessing Keychain items \(error)")
        }
    }
    
    func checkExistingUser(loginName: String) throws -> Bool {
        do {
            return try KeychainPasswordItem.passwordItems(forService: KeychainConfiguration.serviceName, accessGroup: KeychainConfiguration.accessGroup).contains(where: {$0.account == loginName})
        }  catch {
            fatalError("Error accessing Keychain items \(error)")
        }
    }
    
    func loggingUserIn(isExistingUser: Bool, loginName: String, password: String) {
        do {
            if isExistingUser { // Existing user
                if verifyLoginCredentials(username: loginName, password: password) {
                    let loginSuccessAlert = UIAlertController(title: "Welcome Back!", message: "Nice to see you again, \(loginName)", preferredStyle: .alert)
                    loginSuccessAlert.addAction(UIAlertAction(title: "Let's Go", style: .default, handler: { (action: UIAlertAction!) -> Void in
                        self.username = loginName
                        self.performSegue(withIdentifier: "doneWithLogin", sender: self)
                    }))
                    self.present(loginSuccessAlert, animated: true, completion: nil)
                } else {
                    let wrongCredentialsAlert = UIAlertController(title: "Incorrect password", message: "Please check whether password is entered correctly", preferredStyle: .alert)
                    wrongCredentialsAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(wrongCredentialsAlert, animated: true, completion: nil)
                }
            } else { // New user registration
                let passwordItemToAdd: KeychainPasswordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: loginName, accessGroup: KeychainConfiguration.accessGroup)
                try passwordItemToAdd.savePassword(password)
                if verifyLoginCredentials(username: loginName, password: password) {
                    let registerSuccessAlert = UIAlertController(title: "Successfully Registered!", message: "Welcome \(loginName)", preferredStyle: .alert)
                    registerSuccessAlert.addAction(UIAlertAction(title: "Yay!", style: .default, handler:{ (action:UIAlertAction!) -> Void in
                        self.username = loginName
                        self.performSegue(withIdentifier: "doneWithLogin", sender: self)
                    }))
                    self.present(registerSuccessAlert, animated: true, completion: nil)
                }
            }
        } catch {
            fatalError("Error accessing Keychain items \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doneWithLogin" {
            if username != nil {
                if let destinationViewController: ActivityEntriesOverviewController = (segue.destination as? ActivityEntriesOverviewController) {
                    destinationViewController.currentUsername = username
                }
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
        sender.becomeFirstResponder()
    }
    
    @IBAction func loginTextFieldHaltedEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
}
