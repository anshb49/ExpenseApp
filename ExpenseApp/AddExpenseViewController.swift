//
//  AddExpenseViewController.swift
//  ExpenseApp
//
//  Created by Ansh Bhalla on 6/12/20.
//  Copyright © 2020 Ansh Bhalla. All rights reserved.
//

import UIKit

class AddExpenseViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var TotalExpenses = [Expense] ()
    
    @IBOutlet weak var NameInput: UITextField!
    
    @IBOutlet weak var DateInput: UITextField!
    
    @IBOutlet weak var ConfirmAdd: UIButton!
    
    @IBOutlet weak var LeavePage: UIButton!
    
    @IBOutlet weak var AmountIInput: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let Tap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        
        view.addGestureRecognizer(Tap)
        
        
        // Do any additional setup after loading the view.
        
        ConfirmAdd.layer.cornerRadius = 20
        ConfirmAdd.clipsToBounds = true
        
        LeavePage.layer.cornerRadius = 20
        LeavePage.clipsToBounds = true
    }
    
    @objc func DismissKeyboard() {
        view.endEditing(true)
    }

    
    @IBAction func AddExpense(_ sender: Any) {
        let LatestExpense = Expense()
        LatestExpense.name = NameInput.text!
        LatestExpense.date = DateInput.text!
        
       let date = Date()
       let calendar = Calendar.current
       let hour = calendar.component(.hour, from: date)
       let minutes = calendar.component(.minute, from: date)
       LatestExpense.time = String(hour) + ":" + String(minutes)
        
        
        let textAmount = AmountIInput.text!
        let moneyValue = NumberFormatter().number(from: textAmount)?.doubleValue
        LatestExpense.amount = moneyValue!
        
        
        
        print(LatestExpense.name)
        print(LatestExpense.date)
        print(LatestExpense.time)
        print(LatestExpense.amount)

        
        TotalExpenses.append(LatestExpense)
        
        print(TotalExpenses.count)
    }
    
    @IBAction func ResetInputs(_ sender: Any) {
        NameInput.text = ""
        DateInput.text = ""
        //TimeInput.text = ""

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
