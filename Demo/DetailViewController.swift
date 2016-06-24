//
//  DetailViewController.swift
//  Demo
//
//  Created by Ngan Chi Hin on 24/6/2016.
//  Copyright © 2016 Oursky. All rights reserved.
//

import UIKit
import SKYKit

class DetailViewController: UIViewController, UITextViewDelegate {
    
    var noteRow: Int? = nil

    @IBOutlet var composeTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.composeTextView.text = GlobalObject.GlobalVariables.noteArray[self.noteRow!].objectForKey("content") as? String
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add notification about keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddNoteViewController.keyboardDidChangeFrame(_:)), name:UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddNoteViewController.keyboardDidChangeFrame(_:)), name:UIKeyboardWillHideNotification, object: nil)
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
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneEditing)), animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.navigationItem.setRightBarButtonItem(nil, animated: true)
        self.navigationItem.setHidesBackButton(false, animated: true)
    }
    
    func doneEditing() {
        self.composeTextView.resignFirstResponder()
        
        if self.composeTextView.text != "" {
            GlobalObject.GlobalVariables.noteArray[self.noteRow!].setObject(self.composeTextView.text, forKey: "content")
            
            let privateDB = SKYContainer.defaultContainer().privateCloudDatabase
            privateDB.saveRecord(GlobalObject.GlobalVariables.noteArray[self.noteRow!]) { (record: SKYRecord!, error: NSError!) in
                if (error == nil) {
                    // Succeeded
                    print("Object saved successfully: \(record.recordID)")
                    GlobalObject.GlobalVariables.noteArray.removeAtIndex(self.noteRow!)
                    GlobalObject.GlobalVariables.noteArray.insert(record, atIndex: 0)
                } else {
                    // Failed
                    print("Error occured while saving object: \(error)")
                }
            }
        } else {
            // Remove it
            let privateDB = SKYContainer.defaultContainer().privateCloudDatabase
            privateDB.deleteRecordWithID(GlobalObject.GlobalVariables.noteArray[self.noteRow!].recordID, completionHandler: { (recordID: SKYRecordID!, error: NSError!) in
                if (error == nil) {
                    // Succeeded
                    GlobalObject.GlobalVariables.noteArray.removeAtIndex(self.noteRow!)
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    print("Remove object failed: \(error)")
                }
            })
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
