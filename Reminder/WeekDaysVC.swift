//
//  WeekDaysVC.swift
//  Reminder
//
//  Created by ecare on 16/09/18.
//  Copyright © 2018 demodemo. All rights reserved.
//

import UIKit

class WeekDaysVC: UIViewController , UITableViewDataSource , UITableViewDelegate {
    
    // Properties
    var reminders = [Reminder]()
    let dateFormatter = NSDateFormatter()
    let locale = NSLocale.currentLocale()
    let urlString : String = "https://naviadoctors.com/dummy/"
    let weekArr : [String] = ["Sunday" , "Monday" , "Tuesday" , "Wednesday" , "Thursday" , "Friday" , "Saturday"]
    var day = String()
    var remindersToShow = [Reminder]()
    
    //MARK:- Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Enter View Did Load : WeekDaysVC")
        // Do any additional setup after loading the view, typically from a nib.
        day = currentDayOfWeek()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        getJsonFromUrl(day , tag : false)
        // load saved reminders, if any
        if let savedReminders = loadReminders() {
            reminders += savedReminders
        }
        
        }
    
    
    //MARK:- UITableViewDatasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("weekDays", forIndexPath: indexPath)
        
        cell.textLabel?.text = self.weekArr[indexPath.row]
        return cell
    }
    
    //MARK:- UITableView Delegates
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("\(self.weekArr[indexPath.row]) Selected")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let reminder = storyboard.instantiateViewControllerWithIdentifier("Reminder") as! ViewController
        remindersToShow = [Reminder]()
        
        reminder.reminders = self.getJsonFromUrl(self.weekArr[indexPath.row].lowercaseString , tag: true)
        self.navigationController?.pushViewController(reminder, animated: true)
    }

    /*
     * This method is used to save the reminders which are to be shown on their corresponding days.
     *
     * This returns the Reminder Array.
     */
    func saveReminderToShow(name : String , tim : String , tag : Bool) -> [Reminder]{
        print("Saving Reminders to Show")
        //NSDateFormatter Property customization
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var date = dateFormatter.dateFromString(tim)
        
        var time = date?.dateByAddingTimeInterval(Double(-5) * 60)
        
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let now = NSDate().dateByAddingTimeInterval(Double(2) * 60)
        let components = gregorian.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: now)
        let componentsTime = gregorian.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: time!)
        
        componentsTime.day = components.day
        componentsTime.month = components.month
        componentsTime.year = components.year
        
        time = gregorian.dateFromComponents(componentsTime)!
        
        let timeInterval = floor(time!.timeIntervalSinceReferenceDate/60)*60
        time = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        
        // build notification
        let notification = UILocalNotification()
        notification.alertTitle = "Meal Reminder"
        notification.alertBody = "\(name)!"
        notification.fireDate = time
        notification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        //Setting Reminder
        let rem : Reminder = Reminder(name: name, time: time!, notification: notification)
        if(tag == false){
            reminders.append(rem)
            return reminders
        }else{
            remindersToShow.append(rem)
            return remindersToShow
        }
       
        
    }

    /*
     * This method is used find the current day of the week.
     *
     * This returns current day as String.
     */
    func currentDayOfWeek()-> String {
        let customDateFormatter = NSDateFormatter()
        print(NSDate())
        let weekDay = customDateFormatter.weekdaySymbols[NSCalendar.currentCalendar().component(.Weekday, fromDate: NSDate())].lowercaseString
        print("Current Day of Week is : \(weekDay)")
        return weekDay
        
        
    }

    
    // NSCoding
    
    func saveReminders() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(reminders, toFile: Reminder.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save reminders...")
        }
    }
    
    func loadReminders() -> [Reminder]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Reminder.ArchiveURL.path!) as? [Reminder]
    }
    

    
    func getJsonFromUrl(day : String, tag : Bool) -> [Reminder]{
        //creating a NSURL
        let url = NSURL(string: urlString)
        var reminder = [Reminder]()
        
        //Fetching Json Data from the url and setting it in the Reminder.
        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, res, err) in
            if let d = data {
                if let value = String(data: d, encoding: NSASCIIStringEncoding) {
                    if let jsonData = value.dataUsingEncoding(NSUTF8StringEncoding) {
                        do {
                            let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as! [String: AnyObject]
                            let Week_diet_data = json["week_diet_data"] as! [String:AnyObject]
                            print("Week_diet_data is \(Week_diet_data)")
                    
                            if let day = Week_diet_data[day]  {
                                for item in day as! NSArray
                                {
                                    let food = item["food"] as? String
                                    let meal_time = item["meal_time"] as? String
                                    reminder = self.saveReminderToShow(food!, tim: meal_time! , tag: tag)
                                    print("Remnder Added \(reminder)")
                                    
                                }
                            } else {
                                // the value of someOptional is not set (or nil).
                            }
                            
                        } catch {
                            print("Error Catch")
                        }
                        
                    }
                }
                
            }
        }).resume()
        if(tag == false){
            return reminders
        }
        return remindersToShow
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
