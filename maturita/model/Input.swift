//
//  Input.swift
//  maturita
//
//  Created by grabherr on 02.04.2021.
//

import Foundation
import RealmSwift

class Input: Object {
    @objc dynamic var number: Int = 0 //number for correct order
    @objc dynamic var option: Int = 0 //documented which cell user clicked on (not for input)
    @objc dynamic var input: String = "" //documented what user typed in (not for multiple choice)
    convenience init(x: Int, o: Int, i: String) {
        self.init()
        self.number = x
        self.option = o
        self.input = i
    }
    var parentClass = LinkingObjects(fromType: Test.self, property: "input")
}
