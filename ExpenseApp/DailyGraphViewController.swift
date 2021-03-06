//
//  DailyGraphViewController.swift
//  ExpenseApp
//
//  Created by Praval Telagi on 7/21/20.
//  Copyright © 2020 Ansh Bhalla. All rights reserved.
//

import UIKit
import CoreData
import TinyConstraints
import Charts

class DailyGraphViewController: UIViewController {

    let daysOnGraph = 7
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(barChartView)
        barChartView.centerInSuperview()
        barChartView.width(to: view)
        barChartView.heightToWidth(of: view)
        //barChartView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
        barChartView.center = view.center
        
        setData()
        // Do any additional setup after loading the view.
    }
    
    lazy var barChartView: BarChartView = {
        let barView = BarChartView()
        barView.backgroundColor = UIColor(red: (33/255.0), green: (33/255.0), blue: (33/255.0), alpha: 1.0)
        barView.xAxis.labelPosition = .bottom
        barView.xAxis.labelHeight = 100
        barView.xAxis.labelWidth = 20
        barView.xAxis.granularity = 1
        barView.xAxis.setLabelCount(12, force: false)
        barView.rightAxis.enabled = false
        barView.leftAxis.enabled = false
        barView.xAxis.labelTextColor = .white
        barView.animate(yAxisDuration: 1.20)
        
        return barView
    }()
    
    func setData() {
        let set1 = BarChartDataSet(entries: LoadData(), label:"")
        set1.colors = ChartColorTemplates.joyful()
        set1.valueTextColor = .white
        set1.barShadowColor = .white
        
        let data = BarChartData(dataSet:set1)
        
        barChartView.data = data
        
    }
    
    func LoadData() -> [BarChartDataEntry] {
        var dailyExpenseVals = [BarChartDataEntry]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyGraphTestEntity")
        request.returnsObjectsAsFaults = false
        
        var labelDates = [String]()
        
        do {
            let result = try context.fetch(request)
            
            let dataArray = result as! [NSManagedObject]
            var loopCounter = 1
            for data in dataArray.reversed() {
                if (loopCounter == daysOnGraph + 1) {
                    break
                }
                
                /*let yPos = data.value(forKey: "weeklyTotal") as! Double
                labelDates.insert(data.value(forKey: "week") as! String, at: 0)
                weeklyExpenseVals.append(BarChartDataEntry(x: Double(WeeksOnGraph - loopCounter), y: yPos))*/
                
                let yPos = data.value(forKey: "dailyTotal") as! Double
                print(yPos)
                labelDates.insert(data.value(forKey: "date") as! String, at: 0)
                print(data.value(forKey: "date") as! String)
                dailyExpenseVals.append(BarChartDataEntry(x: Double(daysOnGraph - loopCounter), y: yPos))
                
                loopCounter += 1
            }
            
            if (dataArray.count <= daysOnGraph && loopCounter != daysOnGraph + 1) {
                for _ in loopCounter...daysOnGraph {
                    labelDates.insert("", at: 0)
                }
            }
            
            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labelDates)
            
        } catch {
            print("FAILED")
        }
        
        return dailyExpenseVals
    }


    @IBAction func CloseDailyGraph(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
