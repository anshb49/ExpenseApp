//
//  AddExpenseViewController.swift
//  ExpenseApp
//
//  Created by Ansh Bhalla on 6/12/20.
//  Copyright © 2020 Ansh Bhalla. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import Vision
import VisionKit



class AddExpenseViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    
    var textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
    private let textRecognitionWorkQueue = DispatchQueue(label: "MyVisionScannerQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var TotalExpenses = [Expense] ()
    var LastExpense = Expense()
    var number = Int()
    var name = String()
    var date = String()
    var amount = Double()
    let currentEntityName = "DeleteTestingEntity"
    let monthDataEntityName = "MonthlyGraphTestEntity"
    let weekDataEntityName = "WeeklyGraphTestEntity"
    
    
    
    @IBOutlet weak var NameInput: UITextField!
    
    @IBOutlet weak var DateInput: UITextField!
    
    @IBOutlet weak var ConfirmAdd: UIButton!
    
    @IBOutlet weak var LeavePage: UIButton!
    
    @IBOutlet weak var AmountIInput: UITextField!
    
    @IBOutlet weak var DeleteLastExpenseTestButton: UIButton!
    
    @IBOutlet weak var TestLabel: UILabel!
    
    @IBOutlet weak var camera: UIButton!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let Tap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        
        view.addGestureRecognizer(Tap)
        
        
        // Do any additional setup after loading the view.
        
        ConfirmAdd.layer.cornerRadius = 20
        ConfirmAdd.clipsToBounds = true
        
        LeavePage.layer.cornerRadius = 20
        LeavePage.clipsToBounds = true
        
        camera.layer.cornerRadius = 20
        camera.clipsToBounds = true
        
        
        

        //DeleteAllDataInMonthEntity()
        //DeleteAllDataInDailyEntity()
        //GetData()
        
        setupVision()
        print("HELLO THIS IS THE VIEW CONTROLLER CHECKPOINT")
    }
    
    @objc func DismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func AddExpense(_ sender: Any) {
        
        let LatestExpense = Expense()
        LatestExpense.name = NameInput.text!
        //LatestExpense.date = DateInput.text!

        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        LatestExpense.time = String(hour) + ":" + String(minutes)


        let textAmount = AmountIInput.text!
        
        let moneyValue = NumberFormatter().number(from: textAmount)?.doubleValue
        
        if (moneyValue == nil) {
            let alertController = UIAlertController(title: "Amount Format Error", message:
                "There seems to be an Error with the Amount Format", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Retry", style: .default))
            

            self.present(alertController, animated: true, completion: nil)
            return
        } else {
            LatestExpense.amount = moneyValue!
        }
        
        
        

        SaveData(purchaseName: LatestExpense.name, dateOfPurchase: LatestExpense.date, purchaseAmount: LatestExpense.amount)
        GetData()
        //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
    }
    
    @IBAction func ResetInputs(_ sender: Any) {
        NameInput.text = ""
        //DateInput.text = ""
        //TimeInput.text = ""
    }
    
    func GetMonthlyTotal() -> Double {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: monthDataEntityName)
        request.returnsObjectsAsFaults = false
        
        do {
            var result = try context.fetch(request)
            let latestMonthAmount = (result.last as! NSManagedObject).value(forKey: "monthlyTotal") as! Double
            context.delete(result.popLast() as! NSManagedObject)
            try context.save()
            return latestMonthAmount
        } catch {
            print("COULDN'T DELETE")
        }
        
        return 0.0
    }
    
    func SaveData(purchaseName: String, dateOfPurchase: String, purchaseAmount: Double) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: currentEntityName, in: context)
        let newEntity = NSManagedObject(entity: entity!, insertInto: context)
        
        print(purchaseName)
        
        newEntity.setValue(purchaseName, forKey: "nameOfPurchase")
        newEntity.setValue(DateFunctions.GetTodaysDate(), forKey: "dateOfPurchase")
        newEntity.setValue(purchaseAmount, forKey: "purchaseAmount")
        AddLatestExpenseToMonthlyTotal(purchaseAmount: purchaseAmount)
        AddLatestExpenseToWeeklyTotal(purchaseAmount: purchaseAmount)
        AddLatestExpenseToDailyTotal(purchaseAmount: purchaseAmount)
        do {
            try context.save()
            print("SAVED")
        } catch {
            print("ERROR SAVING")
        }
    }
    
    func AddLatestExpenseToWeeklyTotal(purchaseAmount: Double) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: weekDataEntityName)
        request.returnsObjectsAsFaults = false
        var weeklyTotal = 0.0
        var previousDate = String()
        do {
            var result = try context.fetch(request)
            let currentWeeklyTotal = result.popLast() as! NSManagedObject
            weeklyTotal = currentWeeklyTotal.value(forKey: "weeklyTotal") as! Double
            //context.delete(result.popLast() as! NSManagedObject)
            previousDate = currentWeeklyTotal.value(forKey: "week") as! String
            
            context.delete(currentWeeklyTotal)
            try context.save()
            
            
            let entity = NSEntityDescription.entity(forEntityName: weekDataEntityName, in: context)
            let newEntity = NSManagedObject(entity: entity!, insertInto: context)
            
            newEntity.setValue(weeklyTotal + purchaseAmount, forKey: "weeklyTotal")
            newEntity.setValue(previousDate, forKey: "week")
            
            try context.save()
            result = try context.fetch(request)
            
            /*for data in result as! [NSManagedObject] {
                print(data.value(forKey: "monthlyTotal") as! Double)
            }*/
        } catch {
            print("COULDN'T DELETE")
        }
    }
    
    func DeleteLatestExpenseFromWeeklyTotal(purchaseAmount: Double) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: weekDataEntityName)
        request.returnsObjectsAsFaults = false
        var weeklyTotal = 0.0
        var previousDate = String()
        do {
            var result = try context.fetch(request)
            let currentWeeklyTotal = result.popLast() as! NSManagedObject
            weeklyTotal = currentWeeklyTotal.value(forKey: "weeklyTotal") as! Double
            previousDate = currentWeeklyTotal.value(forKey: "week") as! String
            context.delete(currentWeeklyTotal)
            try context.save()
            
            
            let entity = NSEntityDescription.entity(forEntityName: weekDataEntityName, in: context)
            let newEntity = NSManagedObject(entity: entity!, insertInto: context)
            
            newEntity.setValue(weeklyTotal - purchaseAmount, forKey: "weeklyTotal")
            newEntity.setValue(previousDate, forKey: "week")
            
            try context.save()
            result = try context.fetch(request)
            
        } catch {
            print("COULDN'T DELETE")
        }
    }
    
    func AddLatestExpenseToMonthlyTotal(purchaseAmount: Double) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: monthDataEntityName)
        request.returnsObjectsAsFaults = false
        var monthlyTotal = 0.0
        do {
            var result = try context.fetch(request)
            let currentMonthlyTotal = result.popLast() as! NSManagedObject
            monthlyTotal = currentMonthlyTotal.value(forKey: "monthlyTotal") as! Double
            //context.delete(result.popLast() as! NSManagedObject)
            context.delete(currentMonthlyTotal)
            try context.save()
            
            
            let entity = NSEntityDescription.entity(forEntityName: monthDataEntityName, in: context)
            let newEntity = NSManagedObject(entity: entity!, insertInto: context)
            
            newEntity.setValue(monthlyTotal + purchaseAmount, forKey: "monthlyTotal")
            newEntity.setValue(DateFunctions.GetCurrentMonthAndYear(), forKey: "month")
            
            try context.save()
            result = try context.fetch(request)
            
            /*for data in result as! [NSManagedObject] {
                print(data.value(forKey: "monthlyTotal") as! Double)
            }*/
        } catch {
            print("COULDN'T DELETE")
        }
    }
    
    func DeleteLatestExpenseFromMonthlyTotal(purchaseAmount: Double) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: monthDataEntityName)
        request.returnsObjectsAsFaults = false
        
        var monthlyTotal = 0.0
        do {
            var result = try context.fetch(request)
            let currentMonthlyTotal = result.popLast() as! NSManagedObject
            monthlyTotal = currentMonthlyTotal.value(forKey: "monthlyTotal") as! Double
            context.delete(currentMonthlyTotal)
            try context.save()
            
            
            let entity = NSEntityDescription.entity(forEntityName: monthDataEntityName, in: context)
            let newEntity = NSManagedObject(entity: entity!, insertInto: context)
            
            newEntity.setValue(monthlyTotal - purchaseAmount, forKey: "monthlyTotal")
            newEntity.setValue(DateFunctions.GetCurrentMonthAndYear(), forKey: "month")
            
            try context.save()
            result = try context.fetch(request)
            
        } catch {
            print("COULDN'T DELETE")
        }
    }
    
    func AddLatestExpenseToDailyTotal(purchaseAmount: Double) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyGraphTestEntity")
        request.returnsObjectsAsFaults = false
        var dailyTotal = 0.0
        do {
            var result = try context.fetch(request)
            let currentDailyTotal = result.popLast() as! NSManagedObject
            dailyTotal = currentDailyTotal.value(forKey: "dailyTotal") as! Double
            //context.delete(result.popLast() as! NSManagedObject)
            context.delete(currentDailyTotal)
            try context.save()
            
            
            let entity = NSEntityDescription.entity(forEntityName: "DailyGraphTestEntity", in: context)
            let newEntity = NSManagedObject(entity: entity!, insertInto: context)
            
            newEntity.setValue(dailyTotal + purchaseAmount, forKey: "dailyTotal")
            newEntity.setValue(DateFunctions.GetTodaysDate(), forKey: "date")
            
            try context.save()
            result = try context.fetch(request)
            
            /*for data in result as! [NSManagedObject] {
                print(data.value(forKey: "monthlyTotal") as! Double)
            }*/
        } catch {
            print("COULDN'T DELETE")
        }
    }
    
    func DeleteLatestExpenseFromDailyTotal(purchaseAmount: Double) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyGraphTestEntity")
        request.returnsObjectsAsFaults = false
        
        var dailyTotal = 0.0
        do {
            var result = try context.fetch(request)
            let currentDailyTotal = result.popLast() as! NSManagedObject
            dailyTotal = currentDailyTotal.value(forKey: "dailyTotal") as! Double
            context.delete(currentDailyTotal)
            try context.save()
            
            
            let entity = NSEntityDescription.entity(forEntityName: "DailyGraphTestEntity", in: context)
            let newEntity = NSManagedObject(entity: entity!, insertInto: context)
            
            newEntity.setValue(dailyTotal - purchaseAmount, forKey: "dailyTotal")
            newEntity.setValue(DateFunctions.GetTodaysDate(), forKey: "date")
            
            try context.save()
            result = try context.fetch(request)
            
        } catch {
            print("COULDN'T DELETE")
        }
    }
    
    func DeleteLastExpense() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: currentEntityName)
        request.returnsObjectsAsFaults = false
        
        
        
        
        do {
            var result = try context.fetch(request)
            
            let resultCount = (result as! [NSManagedObject]).count
            
            if (resultCount == 0) {
                let alertController = UIAlertController(title: "No Expenses To Delete", message:
                    "There are no Expenses logged to delete", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                

                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            let lastPurchaseAmount = (result.last as! NSManagedObject).value(forKey: "purchaseAmount") as! Double
            context.delete(result.popLast() as! NSManagedObject)
            DeleteLatestExpenseFromMonthlyTotal(purchaseAmount: lastPurchaseAmount)
            DeleteLatestExpenseFromWeeklyTotal(purchaseAmount: lastPurchaseAmount)
            DeleteLatestExpenseFromDailyTotal(purchaseAmount: lastPurchaseAmount)
            try context.save()
        } catch {
            print("COULDN'T DELETE")
        }
    }
    
    func GetData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: currentEntityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in (result as! [NSManagedObject]) {
                //name = data.value(forKey: "nameOfPurchase") as! String
                name = data.value(forKey: "nameOfPurchase") as? String ?? "NO STORE PROVIDED"
                date = data.value(forKey: "dateOfPurchase") as? String ?? "NO DATE PROVIDED"
                amount = data.value(forKey: "purchaseAmount") as? Double ?? 0.00
                print(name)
                print(date)
                print(amount)
                print("")
            }
        } catch {
            print("FAILED")
        }
    }
    
    @IBAction func tryToDeleteStuff(_ sender: Any) {
        DeleteLastExpense()
    }
    
    func DeleteAllDataInMonthEntity() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: currentEntityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            print((result as! [NSManagedObject]).count)
            
            
            
            for data in (result as! [NSManagedObject]).reversed()  {
                context.delete(data)
                try context.save()
                print(result.count)
            }
        } catch {
            print("COULDN'T DELETE")
        }
        
        
        print("THAT NUMBER ABOVE SHOULD BE ZERO")
    }
    
    func DeleteAllDataInDailyEntity() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyGraphTestEntity")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            print((result as! [NSManagedObject]).count)
            for data in (result as! [NSManagedObject]).reversed()  {
                context.delete(data)
                try context.save()
                print(result.count)
            }
        } catch {
            print("COULDN'T DELETE")
        }
        
        
        print("THAT NUMBER ABOVE SHOULD BE ZERO")
    }
    
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func ScanReceipt(_ sender: Any) {
        print("Receipt Scanned")
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = self
        present(scannerViewController, animated: true)
    }
    
    var nameIsPrinted = false
    
    private func setupVision() {
        textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var detectedText = ""
            var counter = 0
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                print("text \(topCandidate.string) has confidence \(topCandidate.confidence)")
                counter += 1
                print(counter)
                detectedText += topCandidate.string
                detectedText += "\n"
                
            
            }
            
            DispatchQueue.main.async {
                
                if !self.nameIsPrinted {
                    self.NameInput.text = detectedText
                    self.nameIsPrinted = true
                } else {
                    self.AmountIInput.text = detectedText
                }
                
                
                //self.TestLabel.flashScrollIndicators()

            }
        }

        textRecognitionRequest.recognitionLevel = .accurate
    }
    
    private func processImage(_ image: UIImage) {
        //imageView.image = image
        recognizeTextInImage(image)
    }
    
    private func recognizeTextInImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        AmountIInput.text = ""
        textRecognitionWorkQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([self.textRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        if (scan.pageCount > 1) {
            let originalImage = scan.imageOfPage(at: 0)
            let receiptImage = scan.imageOfPage(at: 1)
            let newImage = compressedImage(originalImage)
            let newReceiptImage = compressedImage(receiptImage)
            controller.dismiss(animated: true)
            
            
            processImage(newImage)
            processImage(newReceiptImage)
        } else {
            let originalImage = scan.imageOfPage(at: 0)
            
            let newImage = compressedImage(originalImage)
            
            controller.dismiss(animated: true)
            processImage(newImage)
            nameIsPrinted = true
        }
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print(error)
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }

    func compressedImage(_ originalImage: UIImage) -> UIImage {
        guard let imageData = originalImage.jpegData(compressionQuality: 1),
            let reloadedImage = UIImage(data: imageData) else {
                return originalImage
        }
        return reloadedImage
    }
    
}
