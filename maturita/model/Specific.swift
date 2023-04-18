//
//  Specific.swift
//  maturita
//
//  Created by grabherr on 30.03.2021.
//

import Foundation
import RealmSwift

class Specific: Object {
    @objc dynamic var number: Int = 0 //number for correct order
    @objc dynamic var name: String = "" //name
    @objc dynamic var session: Int = 0 //number that keeps track of the question number where the user left of
    @objc dynamic var limit: Int = 0 //number of questions in test
    @objc dynamic var fullPoint: Int = 0 //maximum points that can be reached in test
    @objc dynamic var time: Int = 0 //maximum time for test completion
    @objc dynamic var one: Int = 0 //buttom boundary from interval to get mark 1
    @objc dynamic var two: Int = 0 //buttom boundary from interval to get mark 2
    @objc dynamic var three: Int = 0 //buttom boundary from interval to get mark 3
    @objc dynamic var four: Int = 0 //buttom boundary from interval to get mark 4
    convenience init(x: Int, n: String, s: Int, l: Int, f: Int, t: Int, one: Int, two: Int, three: Int, four: Int) {
        self.init()
        self.number = x
        self.name = n
        self.session = s
        self.limit = l
        self.fullPoint = f
        self.time = t
        self.one = one
        self.two = two
        self.three = three
        self.four = four
    }
    var parentClass = LinkingObjects(fromType: Option.self, property: "specific")
    let test = List<Test>()
    let result = List<Result>()
}
