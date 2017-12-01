//
//  CalendarViewController.swift
//  Boost
//
//  Created by Kelly Herron on 11/13/17.
//  Copyright © 2017 Kelly Herron. All rights reserved.
//

import UIKit
import EventKit

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CalendarAddedDelegate {
    
    @IBOutlet weak var needPermissionView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var calendars: [EKCalendar]?
    
    //let dataArray = ["Calendar 1", "Calendar 2", "Calendar 3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCalendarAuthorizationStatus()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkCalendarAuthorizationStatus()
    }
    
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            // Things are in line with being able to show the calendars in the table view
            loadCalendars()
            refreshTableView()
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // We need to help them give us permission
            needPermissionView.fadeIn()
        }
    }
    
    func requestAccessToCalendar() {
        EKEventStore().requestAccess(to: .event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    self.loadCalendars()
                    self.refreshTableView()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.needPermissionView.fadeIn()
                })
            }
        })
    }
    
    func loadCalendars() {
        self.calendars = EKEventStore().calendars(for: EKEntityType.event).sorted() { (cal1, cal2) -> Bool in
            return cal1.title < cal2.title
        }
    }
    
    func refreshTableView() {
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    @IBAction func goToSettingsButtonTapped(_ sender: UIButton) {
        let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(openSettingsUrl!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let calendars = self.calendars {
            return calendars.count
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell")!
        
        if let calendars = self.calendars {
            let calendarName = calendars[(indexPath as NSIndexPath).row].title
            cell.textLabel?.text = calendarName
        } else {
            cell.textLabel?.text = "Unknown Calendar Name"
        }
        
        return cell
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let identifier = segue.identifier {
//            switch identifier {
//            case SegueIdentifiers.showAddCalendarSegue:
//                let destinationVC = segue.destination as! UINavigationController
//                let addCalendarVC = destinationVC.viewControllers[0] as! AddCalendarViewController
//                addCalendarVC.delegate = self
//            case SegueIdentifiers.showEventsSegue:
//                //                let destinationVC = segue.destinationViewController as! UINavigationController
//                let eventsVC = segue.destination as! EventsViewController
//                let selectedIndexPath = calendarsTableView.indexPathForSelectedRow!
//
//                eventsVC.calendar = calendars?[(selectedIndexPath as NSIndexPath).row]
//            default: break
//            }
//        }
//    }
    
    // MARK: Calendar Added Delegate
    func calendarDidAdd() {
        self.loadCalendars()
        self.refreshTableView()
    }
}
