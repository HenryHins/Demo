//
//  AddNoteViewController.swift
//  Demo
//
//  Created by Ngan Chi Hin on 24/6/2016.
//  Copyright © 2016 Oursky. All rights reserved.
//

import UIKit
import SKYKit

class AddNoteViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var composeTextView: UITextView!
    
    @IBAction func cancel(sender: AnyObject) {
        self.composeTextView.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createNote(sender: AnyObject) {
        if composeTextView.text != "" {
            // Do not save if there is no text
            let note = SKYRecord.init(recordType: "note")
            note.setObject(self.composeTextView.text, forKey: "content")
            
            let privateDB = SKYContainer.defaultContainer().privateCloudDatabase
            privateDB.saveRecord(note) { (record: SKYRecord!, error: NSError!) in
                if (error == nil) {
                    // Succeeded
                    print("Object saved successfully: \(record.recordID)")
                    
                    GlobalObject.GlobalVariables.noteArray.insert(record, atIndex: 0)
                    self.composeTextView.resignFirstResponder()
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    // Failed
                    print("Error occured while saving object: \(error)")
                }
            }
        } else {
            self.composeTextView.resignFirstResponder()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add notification about keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddNoteViewController.keyboardDidChangeFrame(_:)), name:UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddNoteViewController.keyboardDidChangeFrame(_:)), name:UIKeyboardWillHideNotification, object: nil)
        
        self.composeTextView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Change composeTextView inset and make it move as you type so no content gets hidden by the keyboard
    func keyboardDidChangeFrame(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        if notification.name == "UIKeyboardWillChangeFrameNotification" {
            let endKeyboardSize: CGSize = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue.size
            let beginKeyboardSize: CGSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
            
            self.composeTextView.contentInset = UIEdgeInsetsMake(64, 0, endKeyboardSize.height, 0)
            self.composeTextView.scrollIndicatorInsets = self.composeTextView.contentInset
            
            if endKeyboardSize.height > beginKeyboardSize.height { // Scroll only when keyboard frame gets taller
                // Autoscroll after changing frame
                // Delay the following line so that it works properly
                let delay = 0.005 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue()) {
                    let rect = self.composeTextView.caretRectForPosition((self.composeTextView.selectedTextRange?.end)!)
                    let changedRect = CGRectMake(rect.origin.x, rect.origin.y, rect.width, rect.height+3)
                    
                    self.composeTextView.scrollRectToVisible(changedRect, animated: true)
                }
            }
        } else if notification.name == "UIKeyboardWillHideNotification" {
            self.composeTextView.contentInset = UIEdgeInsetsMake(64, 0, 44, 0)
            self.composeTextView.scrollIndicatorInsets = self.composeTextView.contentInset
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
