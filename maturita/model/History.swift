//
//  History.swift
//  maturita
//
//  Created by grabherr on 02.04.2021.
//

import Foundation
import RealmSwift

class History: Object { //close copy of input
    @objc dynamic var number: Int = 0 //number for correct order
    @objc dynamic var option: Int = 0 //documented which cell user clicked on (not for input)
    @objc dynamic var input: String = "" //documented what user typed in (not for multiple choice)
    @objc dynamic var correct: Bool = false //whether quesiton was answered correctly
    convenience init(x: Int, o: Int, i: String, c: Bool) {
        self.init()
        self.number = x
        self.option = o
        self.input = i
        self.correct = c
    }
    var parentClass = LinkingObjects(fromType: Result.self, property: "history")
}

