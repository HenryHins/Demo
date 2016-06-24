//
//  LoginViewController.swift
//  Demo
//
//  Created by Ngan Chi Hin on 21/6/2016.
//  Copyright © 2016 Oursky. All rights reserved.
//

import UIKit
import SKYKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBAction func login(sender: AnyObject) {
        let container = SKYContainer.defaultContainer()
        container.loginWithEmail(usernameField.text, password: passwordField.text) { (user: SKYUser!, error: NSError!) in
            if (error == nil) {
                // Succeeded
                print("Congratulations! \(user!.email) logged in successfully!")
                GlobalObject.GlobalVariables.currentUser = user
                
                let privateDB = SKYContainer.defaultContainer().privateCloudDatabase
                let query = SKYQuery(recordType: "note", predicate: nil)
//                let sortDescriptor = NSSortDescriptor(key: "modificationDate", ascending: false)
//                query.sortDescriptors = [sortDescriptor]
                
                privateDB.performQuery(query) { (results: [AnyObject]!, error: NSError!) in
                    if (error == nil) {
                        // Succeeded
                        
                        for result in results {
                            if result is SKYRecord {
                                GlobalObject.GlobalVariables.noteArray.append(result as! SKYRecord)
                                print(result.modificationDate)
                            }
                        }
                        
//                        print("Objects retrieved successfully: \(GlobalObject.GlobalVariables.noteArray)")
                        
                        // Push to ListNaviController
                        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ListNaviController") {
                            vc.modalTransitionStyle = .FlipHorizontal
                            self.presentViewController(vc, animated: true, completion: nil)
                        }
                        
                    } else {
                        // Failed
                        print("Error occured while retrieving objects: \(error)")
                    }
                }
                
            } else {
                // Failed
                print("Error occured while logging in: \(error)")
                
                if #available(iOS 8.0, *) {
                    let alert = UIAlertController(title: "Oops!", message:"Login failed.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .Default) { _ in })
                    self.presentViewController(alert, animated: true){}
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.loginButton.layer.cornerRadius = 4
        self.signUpButton.layer.cornerRadius = 4
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.usernameField.text = nil
        self.passwordField.text = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
