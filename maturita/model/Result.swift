//
//  Result.swift
//  maturita
//
//  Created by grabherr on 02.04.2021.
//

import Foundation
import RealmSwift

class Result: Object {
    @objc dynamic var number: Int = 0 //number for correct order
    @objc dynamic var name: String = "" //name
    @objc dynamic var folder: String = "" //subject name of result
    @objc dynamic var point: Int = 0 //total points gained
    @objc dynamic var max: Int = 0 //maximum points to be gained
    @objc dynamic var percentage: Float = 0 //percentage of points gained
    @objc dynamic var time: String = "" //time it took for completion
    @objc dynamic var mark: Int = 0 //mark from test
    convenience init(x: Int, n: String, f: String, p: Int, max: Int, pct: Float, t: String, m: Int) {
        self.init()
        self.number = x
        self.name = n
        self.folder = f
        self.point = p
        self.max = m
        self.percentage = pct
        self.time = t
        self.mark = m
    }
    var parentClass = LinkingObjects(fromType: Specific.self, property: "result")
    let history = List<History>()
}
