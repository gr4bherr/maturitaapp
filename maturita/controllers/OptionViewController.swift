//
//  OptionViewController.swift
//  maturita
//
//  Created by grabherr on 29.03.2021.
//

import UIKit
import RealmSwift
import MessageUI
import StoreKit

class OptionViewController: DarkModeViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate { //second screen
    
    @IBOutlet weak var table: UITableView!
    
    let realm = try! Realm()
    var lsSubject = try! Realm().objects(Subject.self)
    var lsResult = try! Realm().objects(Result.self)
    var lsOption: List<Option>!
    
    let darkModeSwitch = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 50
        table.isScrollEnabled = false
        table.tableFooterView = UIView()
        table.backgroundColor = UIColor(named: "Default_wb")
        
        darkModeSwitch.isOn = userDefaults.bool(forKey: "darkMode")
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "\(lsSubject[numSubject].name)", style: .plain, target: nil, action: nil)
        
        title = lsSubject[numSubject].name
    }
    //MARK: - tableview datasource method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //tableview - number of cells
        lsOption = lsSubject[numSubject].option
        return lsOption.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //tableview - content of cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
        cell.textLabel?.text = lsOption[indexPath.row].name
        if lsOption[indexPath.row].name == "Tmavý režim" {
            darkModeSwitch.addTarget(self, action: #selector(didChangeDarkModeSwitch(_:)), for: .valueChanged)
            cell.accessoryView = darkModeSwitch
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        cell.backgroundColor = UIColor(named: "Cell_wb")
        return cell
    }
    //MARK: - tableview delegate method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //tableview - action on press
        switch lsOption[indexPath.row].name {
        case "Zkusit test":
            performSegue(withIdentifier: "SpecificSegue", sender: self)
        case "Vypracované testy":
            performSegue(withIdentifier: "SpecificSegue", sender: self)
        case "Tvoje pokusy":
            performSegue(withIdentifier: "SpecificSegue", sender: self)
        case "Smazat historii pokusů":
            let alert = UIAlertController(title: "Přejete si smazat všechny vaše pokusy?", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ne", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Ano", style: .default) { (anoAction) in
                try! self.realm.write {
                    self.realm.delete(self.realm.objects(Result.self))
                }
            })
            present(alert, animated: true, completion: nil)
        case "Kontakt":
            sendEmail()
        case "Ohodnotit aplikaci":
            SKStoreReviewController .requestReview(in: (view.window?.windowScene)!)
        case "O aplikaci":
            let alert = UIAlertController(title: "O aplikaci", message: "Aplikace od studenta pro studenty.\nAutor aplikace použité testy nevlastní, nýbrž jsou veřejně dostupné na stránkách cermat.cz.\nAplikace slouží pouze ke snadnějšímu vyplňování těchto testů.\nAutor neodpovídá za správnost údajů.\nAutor má právo aplikaci kdykoliv smazat, a to i pokud uživatel zakoupil extra otázky.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Zavřít", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        default:
            print("default")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //prepare for segue
        if segue.identifier == "SpecificSegue" {
            if let indexPath = table.indexPathForSelectedRow {
                numOption = indexPath.row
            }
        }
    }
    func sendEmail() { //send email funtion
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["aplikacematurita@email.cz"])
            present(mail, animated: true)
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    //MARK: - objc func
    @objc func didChangeDarkModeSwitch(_ sender: UISwitch) { //darkmoode switch action
        if sender.isOn {
            userDefaults.setValue(true, forKey: "darkMode")
            NotificationCenter.default.post(name: Notification.Name("darkModeOn"), object: nil)
        } else {
            userDefaults.setValue(false, forKey: "darkMode")
            NotificationCenter.default.post(name: Notification.Name("darkModeOff"), object: nil)
        }
    }
}
