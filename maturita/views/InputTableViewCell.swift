//
//  InputTableViewCell.swift
//  maturita
//
//  Created by grabherr on 01.04.2021.
//

import UIKit
import RealmSwift

class InputTableViewCell: UITableViewCell, UITextFieldDelegate { //input cell
    
    let realm = try! Realm()
    var lsSubject = try! Realm().objects(Subject.self)
    var lsOption: List<Option>!
    var lsSpecific: List<Specific>!
    var lsTest: List<Test>!

    @IBOutlet weak var field: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        field.delegate = self
        field.autocorrectionType = .no
        
        //specification on relevant subfolders
        lsOption = lsSubject[numSubject].option
        lsSpecific = lsOption[0].specific
        lsTest = lsSpecific[numSpecific].test
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    public func configure(text: String, placeholder: String) { //configuration of cell
        field.text = text
        field.backgroundColor = UIColor(named: "Cell_wb")
        field.accessibilityValue = text
        field.accessibilityLabel = placeholder
        field.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Text_bw")!])
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //return function (on enter)
        field.resignFirstResponder()
        try! realm.write {
            lsTest[numTest].input[0].input = (field.text)!
        }
        TestViewController().questionAddSub(num: 1)
        NotificationCenter.default.post(name: Notification.Name("nextQ"), object: nil)
        return true
    }
}
