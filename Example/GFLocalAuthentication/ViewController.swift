//
//  ViewController.swift
//  GFLocalAuthentication
//
//  Created by gualtierofrigerio on 09/28/2018.
//  Copyright (c) 2018 gualtierofrigerio. All rights reserved.
//

import UIKit
import GFLocalAuthentication

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var biometricButton: UIButton!
    
    var gfLocalAuthentication:GFLocalAuthentication?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gfLocalAuthentication = GFLocalAuthentication()
        gfLocalAuthentication?.configureKeychain(service: "MyServiceName", group: nil)
        biometricButton.isEnabled = false
        if let biometricAvailable = gfLocalAuthentication?.isBiometricAuthenticationAvailable(),
           biometricAvailable.available == true {
            if biometricAvailable.type == .biometricTypeTouchID {
                biometricButton.setTitle("Login with TouchID", for: .normal)
            }
            else {
                biometricButton.setTitle("Login with FaceID", for: .normal)
            }
            biometricButton.isEnabled = true
        }
    }

    @IBAction func addAccountTap(_ sender: Any) {
        if  let username = usernameTextField.text,
            let password = passwordTextField.text,
            let authentication = gfLocalAuthentication {
            let added = authentication.addItemInKeychain(account: username, password: password)
            if added == false {
                debugLabel.text = "cannot add item to the keychain"
            }
            else {
                debugLabel.text = "item added to the keychain"
            }
        }
    }
    
    @IBAction func loginTap(_ sender: Any) {
        if  let username = usernameTextField.text,
            let password = passwordTextField.text,
            let authentication = gfLocalAuthentication,
            let storedPassword = authentication.getPasswordFromKeychain(account: username) {
            if password == storedPassword {
                debugLabel.text = "username and password found!"
            }
            else {
                debugLabel.text = "password doesn't match"
            }
        }
        else {
            debugLabel.text = "couldn't get username from the keychain"
        }
    }
    
    @IBAction func loginBiometricTap(_ sender: Any) {
        gfLocalAuthentication?.attempBiometricAuthentication(reason: "login", revertToPasscode: false, callback: { (success) in
            DispatchQueue.main.async { 
                if success == true {
                    self.debugLabel.text = "Biometric authentication passed"
                }
                else {
                    self.debugLabel.text = "Biometric authentication failed"
                }
            }
        })
    }
}

