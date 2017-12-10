//
//  ViewController.swift
//  FirebaseLoginDemo
//
//  Created by Pritam Hinger on 07/12/17.
//  Copyright © 2017 AppDevelapp. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, GIDSignInDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFacebookLoginButtons()
        setupGoogleLoginButton()
    }
    
    fileprivate func setupFacebookLoginButtons() {
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
    
    fileprivate func setupGoogleLoginButton() {
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 182, width: view.frame.width - 32, height: 50)
        view.addSubview(googleButton)
        
        let customGoogleButton = UIButton(type: .system)
        customGoogleButton.frame = CGRect(x: 16, y: 248, width: view.frame.width - 32, height: 50)
        customGoogleButton.setTitle("Custom Google Sign In", for: .normal)
        customGoogleButton.backgroundColor = .orange
        customGoogleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customGoogleButton.setTitleColor(.white, for: .normal)
        customGoogleButton.addTarget(self, action: #selector(handleCustomGoogleSignInClick), for: .touchUpInside)
        view.addSubview(customGoogleButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    @objc func handleCustomGoogleSignInClick(){
        GIDSignIn.sharedInstance().signIn()
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
        let accessToken = FBSDKAccessToken.current()
        guard let aceesTokenString = accessToken?.tokenString else {
                return
        }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: aceesTokenString)
        
        Auth.auth().signIn(with: credentials){ (user, error) in
            if(error != nil){
                print("Error login in to firebase using facebook token : ", error!)
                return
            }
            
            print("Successful logged in into firebase",user ?? "")
        }
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
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error{
            print("Error whiling login with google", error)
            return
        }
        
        print("Logged in successfully with google")
        
        guard let idToken = user.authentication.idToken else { return }
        
        guard let accessToken = user.authentication.accessToken else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if let error = error{
                print("Failed to create a Firebase user with google ", error)
                return
            }
            
            guard let uid = user?.uid else{ return }
            
            print("Successfully logged in into Firebase using Google", uid)
        })
    }
}
