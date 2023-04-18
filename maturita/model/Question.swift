//
//  Question.swift
//  maturita
//
//  Created by grabherr on 31.03.2021.
//

import Foundation
import RealmSwift

class Question: Object {
    @objc dynamic var number: Int = 0 //number for correct order
    @objc dynamic var real: Float = 0 //number displayed on screen
    @objc dynamic var content: String = "" //correct options for type 1 and 2
    @objc dynamic var type: Int = 0 //type of quetion cell (0-nothing, 1-image, 2-audio)
    convenience init(x: Int, r: Float, c: String, t: Int) {
        self.init()
        self.number = x
        self.real = r
        self.content = c
        self.type = t
    }
    var parentClass = LinkingObjects(fromType: Test.self, property: "question")
}
