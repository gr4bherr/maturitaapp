//
//  SpecificViewController.swift
//  maturita
//
//  Created by grabherr on 30.03.2021.
//

import UIKit
import RealmSwift

class SpecificViewController: DarkModeViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    
    let realm = try! Realm()
    var lsSubject = try! Realm().objects(Subject.self)
    var lsResult = try! Realm().objects(Result.self)
    var lsOption: List<Option>!
    var lsSpecific: List<Specific>!
    
    var selectedOption = ""
    var testNumber = 0
    var currentResult: Array<Int> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 50
        table.tableFooterView = UIView()
        table.backgroundColor = UIColor(named: "Default_wb")
        //specification on relevant subfolders
        lsOption = lsSubject[numSubject].option
        lsSpecific = lsOption[0].specific
        
        selectedOption = lsOption[numOption].name
        testNumber = lsSpecific.count
        //sorting result screen descending
        if selectedOption == "Tvoje pokusy" {
            lsResult = lsResult.sorted(byKeyPath: "number", ascending: false)
        }
        //show only result of relevant subject
        for i in 0..<lsResult.count {
            if lsResult[i].folder == lsSubject[numSubject].name {
                currentResult.append(i)
            }
        }
        
        title = lsOption[numOption].name
    }
    //MARK: - tableview datasource method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //tableview - number of cells
        if selectedOption == "Tvoje pokusy" {
            return currentResult.count
        } else {
            return testNumber
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //tableview - content of cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpecificCell", for: indexPath)
        if selectedOption == "Tvoje pokusy" {
            cell.textLabel?.text = "\(lsResult[currentResult[indexPath.row]].name) \(lsResult[currentResult[indexPath.row]].number) (\(Int(lsResult[indexPath.row].percentage))%)"
            cell.textLabel?.textColor = lsResult[currentResult[indexPath.row]].mark != 5 ? #colorLiteral(red: 0.03922171891, green: 0.777918756, blue: 0.04918260127, alpha: 1) : #colorLiteral(red: 0.8535797, green: 0.02476707846, blue: 0.02057315223, alpha: 1) //color of result
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.textLabel?.text = lsSpecific[indexPath.row].name
            if indexPath.row % 2 == 0 && jaro == false { //disabling podzim if not purchased
                cell.textLabel?.textColor = #colorLiteral(red: 0.4956272244, green: 0.4926849008, blue: 0.4978916049, alpha: 1)
                cell.selectionStyle = .none
            } else {
                cell.textLabel?.textColor = UIColor(named: "Default_bw")
                cell.accessoryType = .disclosureIndicator
            }
        }
        cell.backgroundColor = UIColor(named: "Cell_wb")
        return cell
    }
    //MARK: - tableview delegate method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //tableview - action on press
        if indexPath.row % 2 != 0 || jaro {
            performSegue(withIdentifier: "TestSegue", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //prepare for segue
        if let indexPath = table.indexPathForSelectedRow {
            if selectedOption == "Tvoje pokusy" {
                for i in 0..<testNumber { //picking correct result quesitons
                    if lsSpecific[i].name == lsResult[indexPath.row].name {
                        numSpecific = i
                        let destinationVC = segue.destination as! TestViewController
                        destinationVC.numResult = lsResult[indexPath.row].number - 1
                    }
                }
            } else {
                numSpecific = indexPath.row
            }
        }
    }
}
