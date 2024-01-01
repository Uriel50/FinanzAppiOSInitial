//
//  FormatterExtension.swift
//  FinanzApp
//
//  Created by Uriel Candia on 14/12/23.
//

import Foundation

extension Formatter {
    static let dateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
}
