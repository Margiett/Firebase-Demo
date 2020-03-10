//
//  ViewController.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 2/28/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth

//MARK: March 10 Notes  https://console.firebase.google.com/u/3/project/fir-demo-2b103/authentication/users
// go to database and delete all the items and also go to Authentication and delete all the users


enum AccountState {
    case existingUser
    case newUser
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var accountStateMessageLabel: UILabel!
    @IBOutlet weak var accountStateButton: UIButton!
    
    private var accountState: AccountState = .existingUser
    
    private var authSession = AuthenticationSession()
    
    //MARK: March 10th 2020
    private var databaseService = DatabaseService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearErrorLabel()
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        print("login button pressed")
        
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            print("missing info")
            return
        }
        continueLoginFlow(email: email, password: password)
    }
    
    private func continueLoginFlow(email: String, password: String) {
        if accountState == .existingUser {
            authSession.signExistingUser(email: email, password: password) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.errorLabel.text = "\(error.localizedDescription)"
                        self?.errorLabel.textColor = .red
                    }
                case .success:
                    DispatchQueue.main.async {
                        self?.navigateToMainView()
                        
                    }
                }
            }
        } else {
            authSession.createNewUser(email: email, password: password) { [weak self] (result) in
                
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.errorLabel.text = "\(error.localizedDescription)"
                        self?.errorLabel.textColor = .red
                    }
                case .success(let authDataResult):
                    //MARK: March 10th create a database user only from a new authenticated account
                    // make sure this is in the create new user block because you only want to greate a new account for new user and not everyone 
                    self?.createDatabaseUser(authDataResult: authDataResult)
                    break
                  //  DispatchQueue.main.async {
//                        self?.navigateToMainView()
                        
                   // }
                }
            }
        }
    }
    //MARK: March 10th 2020
    private func createDatabaseUser(authDataResult: AuthDataResult) {
        databaseService.createDatabaseUser(authDataResult: authDataResult) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Account error", message: error.localizedDescription)
                }
            case .success:
                DispatchQueue.main.async {
                    self?.navigateToMainView()
                }
            }
            
        }
        
    }
    private func navigateToMainView() {
        UIViewController.showViewController(storyboardName: "MainView", viewControllerId: "MainTabBarController")
    }
    
    private func clearErrorLabel() {
        errorLabel.text = ""
    }
    
    @IBAction func toggleAccountState(_ sender: UIButton) {
        // change the account login state
        accountState = accountState == .existingUser ? .newUser : .existingUser
        
        // animation duration
        let duration: TimeInterval = 1.0
        
        if accountState == .existingUser {
            UIView.transition(with: containerView, duration: duration, options: [.transitionCrossDissolve], animations: {
                self.loginButton.setTitle("Login", for: .normal)
                self.accountStateMessageLabel.text = "Don't have an account ? Click"
                self.accountStateButton.setTitle("SIGNUP", for: .normal)
            }, completion: nil)
        } else {
            UIView.transition(with: containerView, duration: duration, options: [.transitionCrossDissolve], animations: {
                self.loginButton.setTitle("Sign Up", for: .normal)
                self.accountStateMessageLabel.text = "Already have an account ?"
                self.accountStateButton.setTitle("LOGIN", for: .normal)
            }, completion: nil)
        }
    }
    
}

