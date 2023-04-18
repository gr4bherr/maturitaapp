//
//  Option.swift
//  maturita
//
//  Created by grabherr on 29.03.2021.
//

import Foundation
import RealmSwift

class Option: Object {
    @objc dynamic var number: Float = 0 //number for correct order
    @objc dynamic var name: String = "" //name
    convenience init(x: Float, n: String) {
        self.init()
        self.number = x
        self.name = n
    }
    var parentClass = LinkingObjects(fromType: Subject.self, property: "option")
    let specific = List<Specific>()
}
