//
//  WeeklyGraphViewController.swift
//  ExpenseApp
//
//  Created by Praval Telagi on 7/6/20.
//  Copyright © 2020 Ansh Bhalla. All rights reserved.
//

import UIKit
import CoreData
import TinyConstraints
import Charts

class WeeklyGraphViewController: UIViewController {
    
    @IBOutlet weak var WeeklyAverageLabel: UILabel!
    
    let WeeksOnGraph = 6
    let weeklyDataEntityName = "WeeklyGraphTestEntity"

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
        set1.colors = ChartColorTemplates.colorful()
        set1.valueTextColor = .white
        set1.barShadowColor = .white
        
        let data = BarChartData(dataSet:set1)
        
        barChartView.data = data
        
    }
    
    func LoadData() -> [BarChartDataEntry] {
        var weeklyExpenseVals = [BarChartDataEntry]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: weeklyDataEntityName)
        request.returnsObjectsAsFaults = false
        
        var labelDates = [String]()
        var WeeklyTotals = 0.0
        var loopCounter = 0
        
        do {
            let result = try context.fetch(request)
            
            let dataArray = result as! [NSManagedObject]
            
            for data in dataArray.reversed() {
                if (loopCounter + 1 == WeeksOnGraph) {
                    break
                }
                
                let yPos = data.value(forKey: "weeklyTotal") as! Double
                WeeklyTotals += yPos
                labelDates.insert(data.value(forKey: "week") as! String, at: 0)
                weeklyExpenseVals.append(BarChartDataEntry(x: Double(WeeksOnGraph - loopCounter), y: yPos))
                
                loopCounter += 1
            }
            
            if (loopCounter != WeeksOnGraph) {
                for _ in loopCounter...WeeksOnGraph {
                    labelDates.insert("", at: 0)
                }
            }
            
            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labelDates)
            
        } catch {
            print("FAILED")
        }
        
        WeeklyAverageLabel.text = "Past Total Weekly Average: " + "\((WeeklyTotals / Double(loopCounter)).rounded())"
        

        
        return weeklyExpenseVals
    }
    
    
    @IBAction func CloseViewController(_ sender: Any) {
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
