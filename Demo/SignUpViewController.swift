//
//  ViewController.swift
//  Demo
//
//  Created by Ngan Chi Hin on 21/6/2016.
//  Copyright © 2016 Oursky. All rights reserved.
//

import UIKit
import SKYKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func signUp(sender: AnyObject) {
        let container = SKYContainer.defaultContainer()
        container.signupWithEmail(usernameField.text, password: passwordField.text) { (user: SKYUser!, error: NSError!) in
            if (error == nil) {
                // Succeeded
                print("Congratulations! \(user!.email) signed up successfully!")
                GlobalObject.GlobalVariables.currentUser = user
                
                // Push to ListNaviController
                if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ListNaviController") {
                    vc.modalTransitionStyle = .FlipHorizontal
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            } else {
                // Failed
                print("Error occured while signing up: \(error)")
                
                if #available(iOS 8.0, *) {
                    let alert = UIAlertController(title: "Oops!", message:"Signup failed.", preferredStyle: .Alert)
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.usernameField.text = nil
        self.passwordField.text = nil
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

