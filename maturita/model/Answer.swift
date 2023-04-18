//
//  Answer.swift
//  maturita
//
//  Created by grabherr on 31.03.2021.
//

import Foundation
import RealmSwift

class Answer: Object {
    @objc dynamic var number: Float = 0 //number for correct order
    @objc dynamic var content: String = "" //text displayed on screen as different options
    @objc dynamic var placeholder: String = "" //only for Test.swift -> type 5 (placeholder text)
    convenience init(x: Float, c: String, p: String) {
        self.init()
        self.number = x
        self.content = c
        self.placeholder = p
    }
    var parentClass = LinkingObjects(fromType: Test.self, property: "answer")
}
