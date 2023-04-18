//
//  ResultViewController.swift
//  maturita
//
//  Created by grabherr on 02.04.2021.
//

import UIKit
import RealmSwift

class ResultViewController: DarkModeViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm = try! Realm()
    var subjectList = try! Realm().objects(Subject.self)
    
    var subjectNum: Int = 0
    var specificNum: Int = 0
    var timeLeft: Int = 0
    
    var point: Int = 0
    var percentage: Float = 0
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //table
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 50
        table.isScrollEnabled = false
        table.tableFooterView = UIView()
        table.backgroundColor = UIColor(named: "Default_wb")
        //close button
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Zavřít", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ResultViewController.closeBtn(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        //specification on relevant subfolders
        let optionList = subjectList[subjectNum].option
        let specificList = optionList[0].specific
        let testList = specificList[specificNum].test
        let resultList = specificList[specificNum].result
        let resultNum = resultList.count - 1
        let historyList = resultList[resultNum].history

        let maxPoint = specificList[specificNum].fullPoint
        
        try! realm.write {
            calculate(testList: testList, historyList: historyList)
        }
        //values to print
        percentage = (Float(point) / Float(maxPoint)) * 100
        let time = formatTimer(time: specificList[specificNum].time)
        let finalMark = mark(test: specificList[specificNum], pct: percentage)
        let success = finalMark == 5 ? "neprospěl/a" : "prospěl/a"
        
        try! realm.write {
            resultList[resultNum].point = point
            resultList[resultNum].max = maxPoint
            resultList[resultNum].percentage = percentage
            resultList[resultNum].time = time
            resultList[resultNum].mark = finalMark
        }
        label.text = "Počet bodů: \(Int(point))/\(maxPoint)b\nProcentuální úspěšnost: \(Int(percentage))/100%\nUplynulý čas: \(time)\nZnámka: \(finalMark) - \(success)\n\n"
        label.textColor = finalMark == 5 ? #colorLiteral(red: 0.8549297452, green: 0.02462792397, blue: 0.02048231848, alpha: 1) : #colorLiteral(red: 0.04144061357, green: 0.7678096294, blue: 0.04996627569, alpha: 1)
        label.textAlignment = .center
        
        //progress bar update
        progressBar.transform = CGAffineTransform(scaleX: 1, y: 2)
        progressBar.progress = percentage / 100
    }
    //MARK: - tableview datasource method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //tableview - number of cells
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //tableview - contents of cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        cell.backgroundColor = UIColor(named: "Cell_wb")
        cell.textLabel?.text = "Projít test"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    //MARK: - tableview delegate method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //tableview - action on press
        performSegue(withIdentifier: "specificResultSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //prepare for segue
        let destinationVC = segue.destination as! TestViewController
        destinationVC.specificResult = true
    }
    @objc func closeBtn(sender: UIBarButtonItem) { //close results
        self.navigationController?.popToViewController((self.navigationController?.viewControllers[2])!, animated: true)
    }
    func formatTimer(time: Int) -> String { //formating timer (s -> hh:mm:ss)
        let time = time - timeLeft
        let hour = time/3600
        let min = time%3600/60 < 10 ? "0\(time%3600/60)" : "\(time%3600/60)"
        let sec = time%3600%60 < 10 ? "0\(time%3600%60)" : "\(time%3600%60)"
        return "\(hour):\(min):\(sec)"
    }
    func mark(test: Specific, pct: Float) -> Int { //calculating relevant mark
        if pct > Float(test.one) {
            return 1
        } else if Float(test.one) > pct && pct > Float(test.two) {
            return 2
        } else if Float(test.two) > pct && pct > Float(test.three) {
            return 3
        } else if Float(test.three) > pct && pct > Float(test.four) {
            return 4
        } else {
            return 5
        }
    }
    func calculate(testList: List<Test>, historyList: List<History>) { //calculate
        var maximum = 0
        var inputNum = 0
        var i = 0
        while i < testList.count { //going through all questions and allocating relevant points
            maximum += testList[i].maxPoint
            switch testList[i].type {
            case 1: //normal
                if historyList[i].option == testList[i].correct { //if correct, points +1
                    point += testList[i].maxPoint
                    historyList[i].correct = true
                }
                i += 1
            case 2: //yes/no
                var tmpPoint = 0
                for j in i..<i + testList[i].inRow { //going through inrow questions and calculating number of correct ones
                    if historyList[j].option == testList[j].correct {
                        tmpPoint += 1
                        historyList[j].correct = true
                    }
                }
                if tmpPoint == testList[i].inRow { //all questions are correct
                    point += testList[i].maxPoint
                } else if tmpPoint == testList[i].inRow - 1 { //one question is wrong
                    point += testList[i].maxPoint - 1
                }
                i += testList[i].inRow //two or more questions are wrong
            case 3: //order
                var tmpPoint = 0
                for j in i..<i + testList[i].inRow { //going through inrow questions and calculating number of correct ones
                    if historyList[j].option == testList[j].correct {
                        tmpPoint += 1
                        historyList[j].correct = true
                    }
                }
                if tmpPoint == testList[i].inRow { //all quesitons are correct
                    point += testList[i].maxPoint
                }
                i += testList[i].inRow //one or more questions are wrong
            case 4: //words in text
                if historyList[i].input != "" {
                    let inputAnswer = historyList[i].input
                    let answerList = testList[i].answer
                    let answer = answerList[0].content
                    let answerArraySub = answer.split(separator: "|") //splitting options of separate words
                    let inputArraySub = inputAnswer.split(separator: ",") //splitting user input (splitting options of separate words)

                    var answerArray: Array<String> = [] //posible answers
                    var optionArray: Array<Array<String>> = [] //posible answers formated
                    var inputArray: Array<String> = [] //user input
                    var finalArray: Array<String> = [] //user input w/o duplicates

                    for j in 0..<answerArraySub.count { //convertnig possible answers from string.sequence to string array
                        let tmp = String(answerArraySub[j])
                        answerArray.append(tmp)
                    }
                    for j in 0..<inputArraySub.count { //converting user input from string.sequence to string array
                        let tmp = String(inputArraySub[j]).trimmingCharacters(in: .whitespaces)
                        inputArray.append(tmp)
                    }
                    for j in 0..<answerArray.count { //formating posilbe answers
                        let tmpA = answerArray[j].split(separator: "$") //spliting correct options of one word
                        var tmpC: Array<String> = []
                        for k in 0..<tmpA.count {
                            let tmpB = String(tmpA[k])
                            tmpC.append(tmpB)
                        }
                        optionArray.append([""])
                        optionArray[j] = tmpC
                    }
                    for j in 0..<inputArray.count { //replacing duplicates (so user doesn't get more then one point for on word)
                        for k in 0..<inputArray.count {
                            if inputArray[j] == inputArray[k] && j != k {
                                inputArray[j] = "###"
                            }
                        }
                    }
                    finalArray = inputArray.filter {$0 != "###"} //deleting duplicates
                    
                    var tmpPoint = 0
                    for j in 0..<finalArray.count { //counting correct ones
                        for k in 0..<optionArray.count {
                            for l in 0..<optionArray[k].count {
                                if finalArray[j] == optionArray[k][l] {
                                    tmpPoint += 1
                                }
                            }
                        }
                    }
                    
                    if optionArray.count > testList[i].maxPoint { //correct point allocation when there are more points then words needed
                        if tmpPoint == optionArray.count {
                            tmpPoint = testList[i].maxPoint
                        } else {
                            tmpPoint = 0
                        }
                    } else if optionArray.count < testList[i].maxPoint { //correct point allocation when there are less points then words needed
                        if tmpPoint != 0 {
                            tmpPoint = testList[i].maxPoint
                        }
                    }
                    if tmpPoint == testList[i].maxPoint { //"normal" point allocation - when user gets one point for each word
                        historyList[i].correct = true
                    }
                    
//                    print(finalArray)
//                    print(optionArray)
                    point += tmpPoint
                    inputNum += 1
                }
                i += 1
            case 5: //cj2018j13/p13 very specific option (would be too complicated to include in other types
                var tmpPoint = 0
                for j in i..<i + testList[i].inRow {
                    if historyList[j].option == testList[j].correct {
                        tmpPoint += 1
                        historyList[j].correct = true
                    }
                }
                if tmpPoint == testList[i].inRow || tmpPoint == testList[i].inRow - 1 {
                    point += testList[i].maxPoint
                } else if tmpPoint == testList[i].inRow - 2 {
                    point += testList[i].maxPoint - 2
                }
                i += testList[i].inRow
            default:
                print("uncatched case")
            i += 1
            }
//            print("i:\(i), p:\(point)/\(maximum)")
        }
    }
}
