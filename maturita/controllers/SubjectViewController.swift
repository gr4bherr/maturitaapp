//
//  ViewController.swift
//  maturita
//
//  Created by grabherr on 27.03.2021.
//

import UIKit
import RealmSwift
import StoreKit

public var numSubject: Int = 0
public var numOption: Int = 0
public var numSpecific: Int = 0
public var numTest: Int = 0

public func writeCopy(toFile fileURL: URL, encryptionKey: Data? = nil) {}
public var jaro: Bool = false //when false shows only podzim versions of test (free version)

class SubjectViewController: DarkModeViewController, UITableViewDelegate, UITableViewDataSource, SKPaymentTransactionObserver { //first screen
    
    @IBOutlet var table: UITableView!
       
    let realm = try! Realm()
    var lsSubject = try! Realm().objects(Subject.self)
    
    let productID = "com.grabherr.maturita.jaro"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        update()

        table.delegate = self
        table.dataSource = self
        table.rowHeight = 50
        table.isScrollEnabled = false
        table.tableFooterView = UIView()
        table.backgroundColor = UIColor(named: "Default_wb")
        
        let restoreBtn = UIBarButtonItem(title: "Restore", style: UIBarButtonItem.Style.plain, target: self, action: #selector(restoreOnPress))
        navigationItem.setRightBarButton(restoreBtn, animated: true)

        SKPaymentQueue.default().add(self)
        if isPurchased() {
            showJaro()
        }
    }
    //MARK: - tableview datasource method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //tableview - number of cells
        return lsSubject.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //tableview - cell content
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell", for: indexPath)
        cell.textLabel?.text = lsSubject[indexPath.row].name
        cell.backgroundColor = UIColor(named: "Cell_wb")
        
        if indexPath.row == lsSubject.count - 3 {
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(named: "Default_wb")
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    //MARK: - tableview delegate method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //tableview - action upon selecting a row
        if indexPath.row == lsSubject.count - 3 {
            print("nothing happens")
        } else if indexPath.row == lsSubject.count - 1 {
            buyJaro()
        } else {
            performSegue(withIdentifier: "OptionSegue", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = table.indexPathForSelectedRow {
            numSubject = indexPath.row
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { //tableview - hiding purchase cell after succesfull purchase
        if indexPath.row == 6 && jaro {
            return 0
        }
        return tableView.rowHeight
    }
    func buyJaro() { //initialization of purchase
        if SKPaymentQueue.canMakePayments() { //user can make payments
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        }
    }
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) { //payment action
        for i in transactions {
            if i.transactionState == .purchased { //payment successful
                showJaro()
                SKPaymentQueue.default().finishTransaction(i)
            } else if i.transactionState == .restored {
                showJaro()
                SKPaymentQueue.default().finishTransaction(i)
            }
        }
    }
    func isPurchased() -> Bool { //check if user has already purchased
        if UserDefaults.standard.bool(forKey: productID) { //user has already purchased
            return true
        } else {
            return false
        }
    }
    func showJaro() { //action upon purchase
        UserDefaults.standard.set(true, forKey: productID)
        jaro = true
        table.reloadData()
        navigationItem.setRightBarButton(nil, animated: true)
    }
    @objc func restoreOnPress() { //restore function
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    func update() { //function needed incase adding or modifing something is neede (only when releasing new update)
//        let lsOption = lsSubject[0].option //AJ
//        let lsSpecific = lsOption[0].specific //2020 podzim
//        let lsTest = lsSpecific[0].test //test
        //ADD
//        let aj2020p3 = Test(x: 3, c: 2, t: 1, m: 2, i: 1)
//        let aj2020p3a1 = Answer(x: 1, c: "A", i: false)
//        let aj2020p3a2 = Answer(x: 2, c: "B", i: false)
//        let aj2020p3a3 = Answer(x: 3, c: "C", i: false)
//        let aj2020p3a4 = Answer(x: 4, c: "D", i: false)
//        let aj2020p3q1 = Question(x: 1, r: 1, c: """
//    <p><b>1&emsp;Which sport has Joe chosen to do this school year?</b>
//    </p>
//    """, t: 0)
//        let aj2020p3q2 = Question(x: 2, r: 1, c: "aj2020p1.1", t: 1)
//        let aj2020p3q3 = Question(x: 3, r: 1, c: "aj2020p1.2", t: 1)
//        let aj2020p3q4 = Question(x: 4, r: 1, c: "aj2020p1.3", t: 1)
//        let aj2020p3q5 = Question(x: 5, r: 1, c: "aj2020p1.4", t: 1)
//        let aj2020p3q6 = Question(x: 6, r: 1, c: "aj2020p1", t: 2)
//        try! realm.write {
//            lsSpecific[0].test.append(aj2020p3)
//
//            aj2020p3.question.append(aj2020p3q1)
//            aj2020p3.question.append(aj2020p3q2)
//            aj2020p3.question.append(aj2020p3q3)
//            aj2020p3.question.append(aj2020p3q4)
//            aj2020p3.question.append(aj2020p3q5)
//            aj2020p3.question.append(aj2020p3q6)
//            aj2020p3.answer.append(aj2020p3a1)
//            aj2020p3.answer.append(aj2020p3a2)
//            aj2020p3.answer.append(aj2020p3a3)
//            aj2020p3.answer.append(aj2020p3a4)
//        }
        //CHANGE
//        try! realm.write {
//            lsTest[2].correct = 696969696969
//        }
        
    }
}
