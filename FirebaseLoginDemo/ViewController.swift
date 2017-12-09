//
//  ViewController.swift
//  FirebaseLoginDemo
//
//  Created by Pritam Hinger on 07/12/17.
//  Copyright © 2017 AppDevelapp. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = FBSDKLoginButton()
        loginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32 , height: 50)
        view.addSubview(loginButton)
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        
        let customFBButton = UIButton(type: .system)
        customFBButton.backgroundColor = .blue
        customFBButton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
        customFBButton.setTitle("Custom FB Login Here", for: .normal)
        customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customFBButton.setTitleColor(.white, for: .normal)
        view.addSubview(customFBButton)
        
        customFBButton.addTarget(self, action: #selector(handleCustomFBButtonClick), for: .touchUpInside)
    }
    
    @objc func handleCustomFBButtonClick() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self){ (result, error) in
            if(error != nil){
                print("Custom FB Login failed : ", error!)
                return
            }
            
            self.makeGraphRequest() 
        }
    }
    
    fileprivate func makeGraphRequest() {
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start{ (connection, result, error) in
            
            if(error != nil){
                print("Failed to query user's field : ", error!)
                return
            }
            
            print(result!)
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
        }
        
        makeGraphRequest()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Successfully logged out")
    }
}
