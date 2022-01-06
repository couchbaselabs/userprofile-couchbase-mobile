//
//  ViewController.swift
//  UserProfileDemo
//
//  Created by Priya Rajagopal on 2/16/18.
//  Copyright © 2018 Couchbase Inc. All rights reserved.
//

import UIKit

class LoginViewController:UIViewController {
    
    @IBOutlet weak var loginScrollView: UIScrollView!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var passwordEntryView:UIView!
    @IBOutlet weak var passwordTextEntry:UITextField!
    @IBOutlet weak var userEntryView:UIView!
    @IBOutlet weak var userTextEntry:UITextField!
    
    @IBOutlet weak var loginButton:UIButton!
    @IBOutlet weak var bgImageView:UIImageView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    
    // MARK: View Related
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerKBNotifications()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerKBNotifications()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func touchesShouldCancelInContentView(_ view: UIView) -> Bool {
        return true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.passwordTextEntry.text = nil
    }
    
}


// MARK: UITextFieldDelegate
extension LoginViewController:UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool  {
        if textField == self.passwordTextEntry {
            textField.resignFirstResponder()
        }
        else if textField == self.userTextEntry {
            self.passwordTextEntry.becomeFirstResponder()
        }
        return true;
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let length = (textField.text?.count)! - range.length + string.count
        let userLength = (textField == self.userTextEntry) ? length : self.userTextEntry.text?.count
        let passwordLength = (textField == self.passwordTextEntry) ? length : self.passwordTextEntry.text?.count
        
        self.loginButton.isEnabled = (userLength! > 0 && passwordLength! > 0)
        
        return true;
    }
}


// MARK : IBOutlet handlers

extension LoginViewController {
    
    @IBAction func onLoginTapped(_ sender: UIButton) {
        if let userName = self.userTextEntry.text, let password = self.passwordTextEntry.text {
            let cbMgr = DatabaseManager.shared
            
            // First open prebuilt DB with content common to all users
            cbMgr.openPrebuiltDatabase(handler: { [weak self](error) in
                guard let `self` = self else {
                    return
                }

                switch error {
                    
                    case nil:
                        self.activitySpinner.startAnimating()
                        // Open / Create user specific database
                        cbMgr.openOrCreateDatabaseForUser(userName, password: password, handler: { [weak self](error) in
                            
                            guard let `self` = self else {
                                return
                            }
                            
                            switch error {
                                
                            case nil:
                                self.activitySpinner.startAnimating()
                                NotificationCenter.default.post(Notification.notificationForLoginSuccess(userName))
                                self.activitySpinner.stopAnimating()
                                
                            default:
                                self.activitySpinner.startAnimating()
                                NotificationCenter.default.post(Notification.notificationForLoginFailure(userName))
                                self.activitySpinner.stopAnimating()
                                
                            }
                        })
                    
                    default:
                        self.activitySpinner.startAnimating()
                        NotificationCenter.default.post(Notification.notificationForLoginFailure(userName))
                        self.activitySpinner.stopAnimating()

                    }
                })
            }
        }
    
}


// MARK: KB extensions
extension LoginViewController {
    
    func registerKBNotifications() {
        let selectorShow = "kbWillShow:"
        let selectorHide = "kbWillHide:"
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.kbWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.kbWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    func deregisterKBNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func kbWillShow(notification:Notification)-> Void{
        var rect:CGRect = ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey]as? NSValue)?.cgRectValue)!
        rect = self.view.convert(rect, from: nil)
        
        let insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: rect.size.height, right: 0.0)
        self.loginScrollView.contentInset = insets
        self.loginScrollView.scrollIndicatorInsets = insets
        
        var viewRect:CGRect = self.view.frame
        viewRect.size.height = viewRect.size.height - rect.size.height
        if viewRect.contains(loginButton.frame.origin) {
            self.loginScrollView.scrollRectToVisible(self.loginButton.frame, animated: true)
        }
    }
    
    @objc func kbWillHide(notification:Notification)-> Void {
        let insets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        self.loginScrollView.contentInset = insets
        self.loginScrollView.scrollIndicatorInsets = insets
    }
    
    
    
}

