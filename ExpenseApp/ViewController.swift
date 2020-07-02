//
//  ViewController.swift
//  ExpenseApp
//
//  Created by Ansh Bhalla on 6/10/20.
//  Copyright © 2020 Ansh Bhalla. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let currentEntityName = "DeleteTestingEntity"
    let monthDataEntityName = "MonthlyGraphTestEntity"
    
    @IBOutlet weak var RecentStoreLabel: UILabel!
    
    @IBOutlet weak var MonthlyAverage: UIButton!
    
    @IBOutlet weak var WeeklyAverage: UIButton!
    
    @IBOutlet weak var RecentTransaction: UIButton!
    
    @IBOutlet weak var AddExpense: UIButton!
    
    @IBOutlet weak var RecentExpenseLabel: UILabel!
    
    @IBOutlet weak var WeeklyTotalLabel: UILabel!
    
    @IBOutlet weak var MonthlyTotalLabel: UILabel!
    
    @IBOutlet weak var ExpenseSummary: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        MonthlyAverage.layer.cornerRadius = 20
        MonthlyAverage.clipsToBounds = true
        //MonthlyAverage.layer.borderWidth = 1;
        //MonthlyAverage.layer.borderColor = UIColor.init(displayP3Red: 0, green: 255, blue: 162, alpha: 1).cgColor
        
        
        
        WeeklyAverage.layer.cornerRadius = 20
        WeeklyAverage.clipsToBounds = true
        
        RecentTransaction.layer.cornerRadius = 20
        RecentTransaction.clipsToBounds = true
        
        AddExpense.layer.cornerRadius = 20
        AddExpense.clipsToBounds = true
        
        ExpenseSummary.layer.cornerRadius = 20
        ExpenseSummary.clipsToBounds = true
        
        //AddMonthlyTotalTestData()
        //DeleteAllDataInMonthEntity()
        SetupWeekCostSaving()
        SetupMonthCostSaving()
        LoadFrontPageData()
        
    }
    
    func LoadFrontPageData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: currentEntityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            RecentStoreLabel.text = ((result.last as! NSManagedObject).value(forKey: "nameOfPurchase") as! String)
            RecentExpenseLabel.text = "$" + "\((result.last as! NSManagedObject).value(forKey: "purchaseAmount") as! Double)"
            SetMonthlyTotalLabel()
            SetWeeklyTotalLabel()
        } catch {
            print("COULDN'T LOAD FRONT PAGE DATA")
        }
    }
    
    
    
    func SetupMonthCostSaving() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: monthDataEntityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            //print(result.count)
            if ((result as! [NSManagedObject]).count == 0 || (result.last as! NSManagedObject).value(forKey: "month") as! String != GetCurrentMonthAndYear()) {
                let entity = NSEntityDescription.entity(forEntityName: monthDataEntityName, in: context)
                let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                newEntity.setValue(0, forKey: "monthlyTotal")
                newEntity.setValue(GetCurrentMonthAndYear(), forKey: "month")
            }
            
            try context.save()
        } catch {
            print("ERROR")
        }
    }
    
    func SetupWeekCostSaving() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "WeeklyGraphTestEntity")
        request.returnsObjectsAsFaults = false
            
        do {
            let result = try context.fetch(request)
            print(result.count)
            
            
            if ((result as! [NSManagedObject]).count == 0 || !(isInSameWeek(as: ConvertStringToDate(date: ((result.last as! NSManagedObject).value(forKey: "week") as! String))))) {
                let entity = NSEntityDescription.entity(forEntityName: "WeeklyGraphTestEntity", in: context)
                let newEntity = NSManagedObject(entity: entity!, insertInto: context)
                newEntity.setValue(0, forKey: "weeklyTotal")
                newEntity.setValue(GetCurrentDate(), forKey: "week")
            }
            
            try context.save()
        } catch {
            print("ERROR")
        }
    }
    
    
    func DeleteAllDataInMonthEntity() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: monthDataEntityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            print((result as! [NSManagedObject]).count)
            for data in (result as! [NSManagedObject]).reversed() {
                context.delete(data)
                try context.save()
                print(result.count)
            }
        } catch {
            print("COULDN'T DELETE")
        }
        
        print("THAT NUMBER ABOVE SHOULD BE ZERO")
    }
    
    func FullDateToMonthYear(dateToFormat: String) -> String {
        let isoDate = dateToFormat
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "M/dd/yyyy"
        let newDate = dateFormatter.date(from:isoDate)!
        
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "M/yyyy"
        let newDateFormat : String = formatter.string(from: newDate)
        return newDateFormat
    }
    
    func GetCurrentMonthAndYear() -> String {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "M/yyyy"
        let todayMonthYear : String = formatter.string(from:   NSDate.init(timeIntervalSinceNow: 0) as Date)
        return todayMonthYear
    }
    
    func GetCurrentDate() -> String {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "M/dd/yyyy"
        let todayMonthYear : String = formatter.string(from:   NSDate.init(timeIntervalSinceNow: 0) as Date)
        return todayMonthYear
    }
    
    func ConvertStringToDate(date: String) -> Date {
        let isoDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "M/d/yyyy"
        let newDate = dateFormatter.date(from:isoDate)!
        return newDate
    }
    
    
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        return calendar.isDate(Date(), equalTo: date, toGranularity: component)
    }
    
    func isInSameWeek(as date: Date) -> Bool {
        return isEqual(to: date, toGranularity: .weekOfYear)
    }
    
    func SetMonthlyTotalLabel() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: monthDataEntityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            //print((result.last as! NSManagedObject).value(forKey: "monthlyTotal") as! Double)
            let FormattedMonthlyExpense = String(format: "%.2f", (result.last as! NSManagedObject).value(forKey: "monthlyTotal") as! Double)
            MonthlyTotalLabel.text = "$" + "\(FormattedMonthlyExpense)"
            
            /*for data in result as! [NSManagedObject] {
                print(data.value(forKey: "monthlyTotal") as! Double)
            }*/
        } catch {
            print("COULDN'T SET MONTHLY TOTAL LABEL")
        }
    }
    
    func SetWeeklyTotalLabel() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "WeeklyGraphTestEntity")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            print((result.last as! NSManagedObject).value(forKey: "weeklyTotal") as! Double)
            let FormattedWeeklyExpense = String(format: "%.2f", (result.last as! NSManagedObject).value(forKey: "weeklyTotal") as! Double)
            WeeklyTotalLabel.text = "$" + "\(FormattedWeeklyExpense)"
            
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "week") as! String)
                print(data.value(forKey: "weeklyTotal") as! Double)
            }
        } catch {
            print("COULDN'T SET WEEKLY TOTAL LABEL")
        }
    }

}

