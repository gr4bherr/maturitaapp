//
//  TestViewController.swift
//  maturita
//
//  Created by grabherr on 30.03.2021.
//

import UIKit
import RealmSwift
import SwiftySound

class TestViewController: DarkModeViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tableQ: UITableView!
    @IBOutlet weak var tableA: UITableView!
    @IBOutlet weak var aConstraint: NSLayoutConstraint!
    
    let realm = try! Realm()
    var lsSubject = try! Realm().objects(Subject.self)
    var lsInput = try! Realm().objects(Input.self)
    var lsOption: List<Option>!
    var lsSpecific: List<Specific>!
    var lsTest: List<Test>!
    var lsResult: List<Result>!
    var numResult: Int = 0
    
    var specificResult: Bool = false
    
    var tableASize: CGFloat = 0
    var time = 0
    var timer: Timer?
    var userInput: Array<Array<String>> = []
    var optionName: Array<Bool> = []
    
    let redHalf = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.5029490894)
    let greenHalf = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 0.4988358858)
    let red = #colorLiteral(red: 0.8520739675, green: 0, blue: 0, alpha: 1)
    let green = #colorLiteral(red: 0, green: 0.7854649425, blue: 0, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableQ.delegate = self
        tableQ.dataSource = self
        tableQ.register(UINib(nibName: "AudioTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioTableViewCell")
        tableQ.backgroundColor = UIColor(named: "Default_wb")
        
        tableA.delegate = self
        tableA.dataSource = self
        tableA.register(UINib(nibName: "InputTableViewCell", bundle: nil), forCellReuseIdentifier: "InputTableViewCell")
        tableA.backgroundColor = UIColor(named: "Cell_wb")
        
        //specification on relevant subfolders
        lsOption = lsSubject[numSubject].option
        lsSpecific = lsOption[0].specific
        lsTest = lsSpecific[numSpecific].test
        lsResult = lsSpecific[numSpecific].result
        // screen chooser
        if specificResult { //shows corrected test from showresults screen
            optionName = [false, false, true]
        } else {
            if lsOption[numOption].name == "Zkusit test" {
                optionName = [true, false, false]
            }
            else if lsOption[numOption].name == "Vypracované testy" {
                optionName = [false, true, false]
            }
            else { //Tvoje pokusy
                optionName = [false, false, true]
            }
        }
        if optionName[2] { //converting result answers to simple array
            let lsHistory = specificResult ? lsResult[lsResult.count - 1].history : lsResult[numResult].history
            for i in 0..<lsHistory.count {
                userInput.append([String(lsHistory[i].option), lsHistory[i].input, String(lsHistory[i].correct)])
            }
        }
        //end button
        navigationItem.hidesBackButton = true
        let newBackBtn = UIBarButtonItem(title: optionName[0] ? "Ukončit" : "Zavřít", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TestViewController.endBtn(sender:)))
        navigationItem.leftBarButtonItem = newBackBtn
        //center picker button
        let centerPickBtn =  UIButton()
        centerPickBtn.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        centerPickBtn.setTitle("otázky", for: .normal)
        centerPickBtn.setTitleColor(UIColor(named: "Text_bw"), for: .normal)
        centerPickBtn.addTarget(self, action: #selector(pickBtn), for: .touchUpInside)
        navigationItem.titleView = centerPickBtn
        //timer/showresult button
        if optionName[0] { //show timer when "Zkusit test"
            time = lsSpecific[numSpecific].time
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(time/3600):\(time%3600/60 < 10 ? "0\(time%3600/60)" : "\(time%3600/60)"):00", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TestViewController.timerBtn(sender:)))
        } else if optionName[2] { //show button when other option selected
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hodnocení", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TestViewController.ratingBtn(sender:)))
        }
        //swipe initialization
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        //if closed in result test
        if lsSpecific[numSpecific].session == 0 {
            try! realm.write {
                realm.delete(self.realm.objects(Input.self))
            }
        }
        numTest = lsSpecific[numSpecific].session //current question number (from beginning or where user left of)
        try! realm.write {
            if numTest == 0 {
                for i in 0..<lsSpecific[numSpecific].limit {
                    lsTest[i].input.append(Input(x: i, o: 99, i: ""))
                }
            }
        }
        stopAudio() //couldn't inlude this funtion in nextQ(), often thows errors
        nextQ()
    }
    //MARK: - tableview datasource method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //tableview - number of cells
        if tableView == tableQ {
            return lsTest[numTest].question.count
        } else {
            return lsTest[numTest].answer.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //tableview - cell content
        if tableView == tableQ { //QUESTION (tableview 1)
            if lsTest[numTest].question[indexPath.row].type == 1 { //image cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath)
                cell.backgroundColor = UIColor(named: "Default_wb")
                let imgName = lsTest[numTest].question[indexPath.row].content
                let currentImg = UIImage(named: imgName)!
                //scaling image
                let scaleS: CGFloat
                // getting screen size to center image
                if UIScreen.main.bounds.width < 380 {
                    scaleS = 32.5
                } else {
                    scaleS = 40
                }
                let scaleF = currentImg.size.width / tableQ.contentSize.width
                let imgHeight = currentImg.size.height / scaleF - scaleS
                let imgWidth = currentImg.size.width / scaleF - scaleS
                cell.imageView?.image = imageWithImage(image: currentImg, scaleToSize: CGSize(width: imgWidth, height: imgHeight))
                cell.textLabel?.attributedText = nil
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                return cell
            } else if lsTest[numTest].question[indexPath.row].type == 2 { //audio cell (only backend)
                let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell", for: indexPath) as! AudioTableViewCell
                cell.backgroundColor = UIColor(named: "Default_wb")
                cell.configure(file: lsTest[numTest].question[indexPath.row].content)
                return cell
            } else { //text cell ("normal")
                let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath)
                cell.backgroundColor = UIColor(named: "Default_wb")
                let notHtmlText: String = lsTest[numTest].question[indexPath.row].content
                cell.imageView?.image = nil
                cell.textLabel?.attributedText = notHtmlText.htmlToAttributedString
                cell.textLabel?.textColor = UIColor(named: "Text_bw")
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                return cell
            }
        } else { //ANSWER (tableview 2)
            if lsTest[numTest].answer[indexPath.row].placeholder != "" { //input
                tableA.allowsSelection = false
                //initialization of input for current quesition
                let tmp = Input(x: numTest, o: 0, i: "")
                try! realm.write {
                    if lsTest[numTest].input.count != 0 {
                        if lsTest[numTest].input[0].number == tmp.number {
                            lsTest[numTest].input[0].option = tmp.option
                        }
                    } else {
                        lsTest[numTest].input.append(tmp)
                    }
                }
                if optionName[1] { //correct test - selects correct option with green color
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
                    cell.textLabel?.text = formatInput(0)
                    cell.backgroundColor = greenHalf
                    return cell
                } else if optionName[2] { //result test - selects correct option with green color, red when incorrect and selects no color when no input
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
                    if userInput[numTest][2] == "true" { //correct option
                        cell.textLabel?.text = formatInput(1)
                        cell.backgroundColor = greenHalf
                    } else {
                        cell.textLabel?.text = formatInput(2)
                        if userInput[numTest][1] == "" { //no input
                            cell.backgroundColor = UIColor(named: "Cell_wb")
                        } else { //incorrect option
                            cell.backgroundColor = redHalf
                        }
                    }
                    return cell
                } else { //try test
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InputTableViewCell", for: indexPath) as! InputTableViewCell
                    cell.configure(text: lsTest[numTest].input[0].input, placeholder: lsTest[numTest].answer[0].placeholder)
                    cell.backgroundColor = UIColor(named: "Cell_wb")
                    return cell
                }
            } else { //multiple choice
                tableA.allowsSelection = optionName[0] ? true : false
                let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
                cell.textLabel?.text = lsTest[numTest].answer[indexPath.row].content
                cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                cell.backgroundColor = UIColor(named: "Cell_wb")
                if optionName[1] { //correct test - selects correct option with green color
                    if indexPath.row == lsTest[numTest].correct - 1 {
                        cell.backgroundColor = greenHalf
                    }
                    else {
                        cell.backgroundColor = UIColor(named: "Cell_wb")
                    }
                } else if optionName[2] { //result test - selects correct option with green color + red when incorrect and selects no color when no input
                    if userInput[numTest][0] == "99" {
                        cell.backgroundColor = UIColor(named: "Cell_wb")
                    } else if String(indexPath.row + 1) == userInput[numTest][0] || indexPath.row == lsTest[numTest].correct - 1 {
                            if String(indexPath.row + 1) == userInput[numTest][0] {
                                cell.backgroundColor = redHalf
                            }
                            if indexPath.row == lsTest[numTest].correct - 1 {
                                cell.backgroundColor = greenHalf
                            }
                        } else {
                            cell.backgroundColor = UIColor(named: "Cell_wb")
                        }
                } else { //try test
                    cell.backgroundColor = UIColor(named: "Cell_wb")
                    cell.accessoryType = .disclosureIndicator
                }
                return cell
            }
        }
    }
    //MARK: - tableview delegate method - user input
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //tableview - action on press
        tableView.deselectRow(at: indexPath, animated: true)
        let tmp = Input(x: numTest, o: indexPath.row + 1, i: "")
        try! realm.write {
            if lsTest[numTest].input[0].number == tmp.number {
                lsTest[numTest].input[0].option = tmp.option
            }
        }
        questionAddSub(num: 1)
        stopAudio()
        nextQ()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //prepare for segue
        let destinationVC = segue.destination as! ResultViewController
        destinationVC.subjectNum = numSubject
        destinationVC.specificNum = numSpecific
        destinationVC.timeLeft = time
    }
    //MARK: - pickerview - datasource, delegate...
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView { //picker view - easy access to specific questions
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 10, height: 30))
        let question = lsTest[row].question
        label.text = "otázka \(question[0].real.clean)"
        label.sizeToFit()
        if optionName[0] { //try test - no color when some input, red color when no input
            if lsInput[row].option == 99 || (lsInput[row].option == 0 && lsInput[row].input == "") {
                label.textColor = red
            }
        } else if optionName[1] { //correct test - all green color
            label.textColor = green
        } else { //result test - green when correct, red when incorrect, none when no input
            if userInput[row][2] == "true" {
                label.textColor = green
            } else {
                if userInput[row][0] == "99" || (userInput[row][0] == "0" && userInput[row][1] == "") {
                    label.textColor = UIColor(named: "Default_bw")
                } else {
                    label.textColor = red
                }
            }
        }
        return label
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int { //pickerview - number of components
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { //pickerview - number of rows
        return lsTest.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { //picker view - row height
        return 40
    }
    //MARK: - model manipulation method - funcitons
    func imageWithImage (image: UIImage, scaleToSize: CGSize) -> UIImage { //image resizing
        UIGraphicsBeginImageContext(scaleToSize)
        image.draw(in: CGRect(x: 0, y: 0, width: scaleToSize.width, height: scaleToSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.alwaysOriginal)
    }
    func questionAddSub(num: Int) { //question number write
        if num == 0 { //substracting 1
            numTest -= 1
        } else if num == 1 { //adding 1
            numTest += 1
        } else if num == 2 { //reseting numTest
            numTest = 0
        }
        NotificationCenter.default.addObserver(self, selector: #selector(nextQ), name: Notification.Name("nextQ"), object: nil) //listener to pressing enter when input
    }
    func showResult() { //showing result screen
        totalAudioStop()
        var tmp = true
        for i in 0..<lsInput.count { //checking if all question have input
            if lsInput[i].option == 99 || (lsInput[i].option == 0 && lsInput[i].input == "") {
                tmp = false
            }
        }
        let alert = UIAlertController(title: "Přejete si test vyhodnotit?", message: tmp ? "" : "Pozor!\nněkteré otázky zůstaly prázdné", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ne", style: .default) { (neAction) in
            numTest = self.lsSpecific[numSpecific].limit - 1
        })
        alert.addAction(UIAlertAction(title: "Ano", style: .default) { (anoAction) in
            self.performSegue(withIdentifier: "ResultSegue", sender: self)
            //copying Input to Result -> History and then deleting Input
            let tmpR = Result(x: self.lsResult.count + 1, n: self.lsSpecific[numSpecific].name, f: self.lsSubject[numSubject].name, p: 0, max: 0, pct: 0, t: "", m: 0)
            try! self.realm.write {
                self.lsSpecific[numSpecific].session = 0
                self.lsSpecific[numSpecific].result.append(tmpR)
                for i in 0..<self.lsInput.count {
                    let tmpH = History(x: 0, o: 0, i: "", c: false)
                    tmpH.number = self.lsTest[i].input[0].number + 1
                    tmpH.option = self.lsTest[i].input[0].option
                    tmpH.input = self.lsTest[i].input[0].input
                    self.lsResult[tmpR.number - 1].history.append(tmpH)
                }
                self.realm.delete(self.realm.objects(Input.self))
            }
        })
        present(alert, animated: true, completion: nil)
    }
    func showRating() { //show quick view of test detail (not in "Zkusit test")
        totalAudioStop()
        let r = lsResult[numResult]
        let alert = UIAlertController(title: "Hodnocení", message: "Počet bodů: \(Int(r.point))/\(r.max)b\nProcentuální úspěšnost: \(Int(r.percentage))/100%\nUplynulý čas: \(r.time)\nZnámka: \(r.mark) - \(r.mark == 5 ? "neprospěl/a" : "prospěl/a")", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Zavřít", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func endTest() { //ending test and clearing all progress
        totalAudioStop()
        if optionName[0] {
            let alert = UIAlertController(title: "Přejete si test ukončit?", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ano", style: .default) { (action) in
                self.navigationController?.popViewController(animated: true)
                try! self.realm.write {
                    self.lsSpecific[numSpecific].session = 0
                    self.realm.delete(self.realm.objects(Input.self))
                }
            }
            alert.addAction(action)
            
            let cancelAction = UIAlertAction(title: "Ne", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
            try! self.realm.write {
                self.lsSpecific[numSpecific].session = 0
                self.realm.delete(self.realm.objects(Input.self))
            }
        }

    }
    func formatInput(_ type: Int) -> String { //when input -> showing correct option, showing user input, combining user input with correct opiton (not in "Zkusit test")
        var stringOne = ""
        
        let answerList = lsTest[numTest].answer
        let answer = answerList[0].content
        let answerArraySub = answer.split(separator: "|")

        var answerArray: Array<String> = [] //posible answers
        var optionArray: Array<Array<String>> = [] //posible answers formated

        for i in 0..<answerArraySub.count { //convertnig to string array
            let tmp = String(answerArraySub[i])
            answerArray.append(tmp)
        }
        for i in 0..<answerArray.count { //formating posilbe answers
            let tmpA = answerArray[i].split(separator: "$")
            var tmpC: Array<String> = []
            for j in 0..<tmpA.count {
                let tmpB = String(tmpA[j])
                tmpC.append(tmpB)
            }
            optionArray.append([""])
            optionArray[i] = tmpC
        }
        for i in 0..<optionArray.count {
            stringOne += "\(optionArray[i][0])"
            if optionArray[i].count > 1 {
                stringOne += " ("
                for j in 1..<optionArray[i].count {
                    stringOne += "\(optionArray[i][j])"
                    if j != optionArray[i].count - 1 {
                            stringOne += ", "
                    }
                }
                stringOne += ")"
            }
            if i != optionArray.count - 1 {
                    stringOne += ", "
            }
        }
        if type == 0 { //correct test - correct answer
            return stringOne
        } else if type == 1 { //true answer - user input
            return userInput[numTest][1]
        } else { //false answer - user input + correct answer
            return "\(userInput[numTest][1]) (správně: \(stringOne))"
        }
    }
    func stopAudio() { //stops audio if questions do not belong together
        if numTest != 0 && numTest != lsSpecific[numSpecific].limit { //beginning and end assurance, so it doesn't run out of bounds (never need this func in those cases)
            if lsTest[numTest - 1].inRow == 1 || lsTest[numTest].inRow != lsTest[numTest - 1].inRow { //stops music if seperate questions or at the beginning and end of groups of questions
                totalAudioStop()
            }
        }
    }
    func totalAudioStop() { //stops audio no matter what
        Sound.stopAll()
        audioPlaying = false
    }
    //MARK: - objc functions
    @objc func nextQ() { //next question
        if optionName[0] { //checking if user has left of when doing test
            try! realm.write {
                lsSpecific[numSpecific].session = numTest
            }
        }
        tableQ.setContentOffset(.zero, animated: true)
        tableA.setContentOffset(.zero, animated: true)
        if numTest != lsSpecific[numSpecific].limit { //next
            if lsTest[numTest].answer.count == 1 && (optionName[1] || optionName[2]) { //size of row when input and correct test
                tableA.rowHeight = 176
                aConstraint.constant = CGFloat(176)
            } else { //"normal" size of row
                tableA.rowHeight = 44
                aConstraint.constant = CGFloat(lsTest[numTest].answer.count * 44)
            }
            if optionName[0] { //persisting currect progress
                numTest = lsSpecific[numSpecific].session == 0 ? 0 : lsSpecific[numSpecific].session
            }
            title = "\(lsSpecific[numSpecific].name) - \(lsTest[numTest].question[0].real.clean)"
            //animation of question tableview
            tableQ.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 500, 0, 0)
            UIView.animate(withDuration: 0.5) {
                self.tableQ.layer.transform = CATransform3DIdentity
            }
            tableQ.reloadData()
            tableQ.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            tableA.reloadData()
            tableA.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            
//            if optionName[0] {
//                tableA.selectRow(at: IndexPath(row: lsTest[numTest].input[0].option - 1, section: 0), animated: false, scrollPosition: .none)
//            }
        } else { //showing result
            if optionName[0] { //when on last question - show result
                showResult()
            } else {
                questionAddSub(num: 0) //when on first quesiton - nothing
            }
        }
    }
    @objc func endBtn(sender: UIBarButtonItem) { //end test
        endTest()
    }
    @objc func timerBtn(sender: UIBarButtonItem) { //show result
        showResult()
    }
    @objc func ratingBtn(sender: UIBarButtonItem) { //show compact result
        showRating()
    }
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) //swipes
    {
        if sender.direction == .left { //forward
            questionAddSub(num: 1)
            stopAudio()
            nextQ()
        }
        if sender.direction == .right {
            stopAudio()
            if numTest != 0 { //back
                questionAddSub(num: 0)
                title = "\(lsSpecific[numSpecific].name) - \(lsTest[numTest].question[0].real.clean)"
                if lsTest[numTest].answer.count == 1 && (optionName[1] || optionName[2]) {
                    tableA.rowHeight = 176
                    aConstraint.constant = CGFloat(176)
                } else {
                    tableA.rowHeight = 44
                    aConstraint.constant = CGFloat(lsTest[numTest].answer.count * 44)
                }
                
                tableQ.layer.transform = CATransform3DTranslate(CATransform3DIdentity, -500, 0, 0)
                UIView.animate(withDuration: 0.5) {
                    self.tableQ.layer.transform = CATransform3DIdentity
                }
                tableQ.reloadData()
                tableA.reloadData()
                
                if optionName[0] {
                    tableA.selectRow(at: IndexPath(row: lsTest[numTest].input[0].option - 1, section: 0), animated: false, scrollPosition: .none)
                }
            } else { //result test
                endTest()
            }
        }
    }
    @objc func updateTimer() { //timer formating and action
        let hour = time/3600
        let min = time%3600/60 < 10 ? "0\(time%3600/60)" : "\(time%3600/60)"
        let sec = time%3600%60 < 10 ? "0\(time%3600%60)" : "\(time%3600%60)"
        
        if time > 0 {
            navigationItem.rightBarButtonItem?.title = "\(hour):\(min):\(sec)"
            time -= 1
        } else {
            navigationItem.rightBarButtonItem?.title = "\(hour):\(min):\(sec)"
            timer!.invalidate()
            showResult()
        }
    }
    @objc func pickBtn() { //picker button action
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 200)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: -25, width: 250, height: 250))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.selectRow(numTest, inComponent: 0, animated: false)
        vc.view.addSubview(pickerView)
        
        let alert = UIAlertController(title: "Vyberte otázku", message: "", preferredStyle: .alert)
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Zpět", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Vybrat", style: .default) { (selectAction) in
            numTest = self.lsTest[pickerView.selectedRow(inComponent: 0)].number - 1
            self.tableA.reloadData() //reload is delayed without this
            self.stopAudio()
            self.nextQ()
        })
        present(alert, animated: true, completion: nil)
    }
}
extension String { //converting string to html
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
extension Float { //removes trailing zeros
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
