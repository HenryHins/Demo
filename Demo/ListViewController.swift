//
//  ListViewController.swift
//  Demo
//
//  Created by Ngan Chi Hin on 24/6/2016.
//  Copyright © 2016 Oursky. All rights reserved.
//

import UIKit
import SKYKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var noteTableView: UITableView!
    
    @IBAction func logout(sender: AnyObject) {
        let container = SKYContainer.defaultContainer()
        container.logoutWithCompletionHandler { (user: SKYUser!, error: NSError!) in
            if (error == nil) {
                // Succeed
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                GlobalObject.GlobalVariables.noteArray = []
                GlobalObject.GlobalVariables.currentUser = nil
                print("User logged out successfully. Current user is: \(GlobalObject.GlobalVariables.currentUser)")
            } else {
                // Failed
                print("Error occured while logging out: \(error)")
                
                if #available(iOS 8.0, *) {
                    let alert = UIAlertController(title: "Oops!", message:"Logout failed.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .Default) { _ in })
                    self.presentViewController(alert, animated: true){}
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    @IBAction func addNote(sender: AnyObject) {
        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("AddNoteNaviController") {
            vc.modalTransitionStyle = .CoverVertical
            self.navigationController?.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.noteTableView.registerNib(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "ListCell")
        
        // Hide the blank cells when the tableView is empty
        self.noteTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.noteTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalObject.GlobalVariables.noteArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.noteTableView.dequeueReusableCellWithIdentifier("ListCell") as! ListTableViewCell
        
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15)
        
        if let content = GlobalObject.GlobalVariables.noteArray[indexPath.row].objectForKey("content") as? String {
            let firstLine = content.componentsSeparatedByString("\n")[0]
            cell.titleLabel.text = firstLine
            
            if content.componentsSeparatedByString("\n").count > 1 {
                // If there is more than one line, it will show the second line of text
                cell.contentLabel.text = (content as NSString).substringFromIndex(firstLine.characters.count).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) // Remove blank spaces
            } else if content.componentsSeparatedByString(" ").count > 15 {
                // If there is one line and there is more than 15 words, then it will show the 16th word
                
                let nWords = 15
                let wordRange = NSMakeRange(0, nWords)
                let firstWords = (content.componentsSeparatedByString(" ") as NSArray).subarrayWithRange(wordRange)
                let result = (firstWords as NSArray).componentsJoinedByString(" ")
                let wordCount = result.characters.count
                
                cell.contentLabel.text = (content as NSString).substringFromIndex(wordCount).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            } else {
                // If it doesn't fit any scenario then it won't show any content
                cell.contentLabel.text = "No additional text"
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as? DetailViewController {
            vc.hidesBottomBarWhenPushed = true
            vc.noteRow = indexPath.row
            self.navigationController?.pushViewController(vc, animated: true)
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
