//
//  Model.swift
//  ProAndCon
//
//  Created by Роман Кабиров on 10.12.2017.
//  Copyright © 2017 Logical Mind. All rights reserved.
//

import Foundation
import UIKit

enum ProAndConResult: Int {
    case yes = 1
    case no = 0
    case unknown = -1
}

class Data {
    static var questions = [Question]()
    
    
    static func save() {
        let url = getStorageFilename("questions")
        NSKeyedArchiver.archiveRootObject(Data.questions, toFile: url.path)
    }
    
    static func load() {
        let url = getStorageFilename("questions")
        if let w = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? [Question] {
            Data.questions = w
        }
    }

    static func getStorageFilename(_ key: String) -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = directory.appendingPathComponent("ProAndCon.\(key)")
        return fileUrl
    }
}

class Question: NSObject, NSCoding {
    var date: Date? = Date()
    var questionText: String? = ""
    var result: ProAndConResult? = .unknown
    var pros = [Argument]()
    var cons = [Argument]()
    
    init(_ text: String) {
        questionText = text
    }

    required init?(coder aDecoder: NSCoder) {
        self.date = aDecoder.decodeObject(forKey: "date") as? Date
        self.questionText = aDecoder.decodeObject(forKey: "questionText") as? String
        let i = aDecoder.decodeInteger(forKey: "result")
        self.result = ProAndConResult(rawValue: i)
        if let pros = aDecoder.decodeObject(forKey: "pros") as? [Argument] {
            self.pros = pros
        }
        if let cons = aDecoder.decodeObject(forKey: "cons") as? [Argument] {
            self.cons = cons
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: "date")
        aCoder.encode(questionText, forKey: "questionText")
        let i: Int = (result?.rawValue)!
        aCoder.encode(i, forKey: "result")
        aCoder.encode(pros, forKey: "pros")
        aCoder.encode(cons, forKey: "cons")
    }
    
    func calculateResult() {
        var prosCount = 0
        var consCount = 0
        for i in pros { prosCount += i.weight! }
        for i in cons { consCount += i.weight! }
        if prosCount > consCount {
            result = .yes
        }
        else
        if prosCount < consCount {
            result = .no
        }
    }

}

class Argument: NSObject, NSCoding {
    var name: String?
    var weight: Int?

    init(name: String, weight: Int) {
        self.name = name
        self.weight = weight
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(Int(weight!), forKey: "weight")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.weight = aDecoder.decodeInteger(forKey: "weight")
    }
}

struct Utils {
    static func getShownResult(result: ProAndConResult) -> String {
        switch result {
        case .no: return "No".localized
        case .yes: return "Yes".localized
        case .unknown: return "Equal".localized
        }
    }
    
    static func getHumanDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }
}

extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
