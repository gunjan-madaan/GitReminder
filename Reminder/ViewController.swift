//
//  ViewController.swift
//  Reminder
//
//  Created by ecare on 16/09/18.
//  Copyright © 2018 demodemo. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {

    // IBOutlet Properties
    @IBOutlet weak var tableView = UITableView()
    
    // Properties
    var reminders : [Reminder]!
    let dateFormatter = NSDateFormatter()
    let locale = NSLocale.currentLocale()
    
    //MARK:- Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Enter View Did Load : ViewController")
        //DateFormatter properties customization
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        
        tableView!.reloadData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        tableView!.reloadData()
    }
    
    /*
     * This method pops the top UIViewController from the Stack.
     *
     */
    @IBAction func BackBtnTapped(sender: AnyObject) {
        print("Back Button Tapped")
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    //MARK:- UITableView DataSources
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "reminderCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        let reminder = reminders[indexPath.row]
        // Fetches the appropriate info if reminder exists
        cell.textLabel?.text = reminder.name
        cell.detailTextLabel?.text = "Due " + dateFormatter.stringFromDate(reminder.time)
        
        // Make due date red if overdue
        if NSDate().earlierDate(reminder.time) == reminder.time {
            cell.detailTextLabel?.textColor = UIColor.redColor()
        }
        else {
            cell.detailTextLabel?.textColor = UIColor.blueColor()
        }
        return cell
    }
    
       
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

