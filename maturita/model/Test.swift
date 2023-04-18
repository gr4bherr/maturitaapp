//
//  Test.swift
//  maturita
//
//  Created by grabherr on 30.03.2021.
//

import Foundation
import RealmSwift

class Test: Object {
    @objc dynamic var number: Int = 0 //number for correct order
    @objc dynamic var correct: Int = 0 //correct option (for type 4 it's 0, this is substituted in Question.swift -> content)
    @objc dynamic var type: Int = 0 //type of question *
    @objc dynamic var maxPoint: Int = 0 //maximum points to be gained from question or group of questions
    @objc dynamic var inRow: Int = 0 //number for questions that need to be graded in a group (type 2, 3 and 5)
    convenience init(x: Int, c: Int, t: Int, m: Int, i: Int) {
        self.init()
        self.number = x
        self.correct = c
        self.type = t
        self.maxPoint = m
        self.inRow = i
    }
    var parentClass = LinkingObjects(fromType: Specific.self, property: "test")
    let question = List<Question>()
    let answer = List<Answer>()
    let input = List<Input>()
}
//**
//type:
//1 - normal (multiple choice - 1 question, 0-1 point)
//2 - yes/no (multiple choice - 4 questions, 0-2 points)
//3 - order (multiple choice - x questions, 0 or maximum points)
//4 - input (text input - x questions, 0-max points)
//5 - specific type only in questions cj2018j13 cj2018p13 (multiple choice - 3 questions, 0,1 or 3 points)
