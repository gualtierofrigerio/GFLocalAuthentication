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
    
    var gfLocalAuthentication:GFLocalAuthentication?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gfLocalAuthentication = GFLocalAuthentication()
        gfLocalAuthentication?.configureKeychain(service: "MyServiceName", group: nil)
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
}

