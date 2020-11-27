//
//  StringExtensions.swift
//  SmartEducation
//
//  Created by MacBook on 11/4/20.
//

import Foundation

extension String {
    static var empty = ""

    var isValidURL: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector?.firstMatch(in: self,
                                            options: [],
                                            range: NSRange(location: 0,
                                                           length: self.utf16.count)) {
            return match.range.length == self.utf16.count
        }

        return false
    }

    func isEmptyOrWhitespace() -> Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
