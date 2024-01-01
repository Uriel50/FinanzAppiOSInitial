//
//  DateExtension.swift
//  FinanzApp
//
//  Created by Uriel Candia on 14/12/23.
//

import Foundation

extension Date {
    var formattedDateString: String {
        return Formatter.dateOnly.string(from: self)
    }
}

