//
//  File.swift
//  
//
//  Created by Victor on 15.11.2019.
//

import Foundation

extension Date {
    func addDays(_ numberOfDays: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: numberOfDays, to: self)
    }
}
