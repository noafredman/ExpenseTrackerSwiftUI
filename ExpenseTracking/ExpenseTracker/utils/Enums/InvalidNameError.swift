//
//  InvalidNameError.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import Foundation

enum InvalidNameError: Error {
    case nameMustConsistOnlyLetters
    case oneNameLength
    case twoNamesLength
    case nameCanHaveUpToTwoWords
    case nameIsEmpty
    
    func message() -> String {
        switch self {
        case .nameMustConsistOnlyLetters:
            "Name must consist of letters alone"
        case .oneNameLength:
            "Name must have 1-20 characters"
        case .twoNamesLength:
            "Both names must have 1-20 characters"
        case .nameCanHaveUpToTwoWords:
            "Name cannot consist of more than 2 names"
        case .nameIsEmpty:
            "Name cannot be empty"
        }
    }
}
