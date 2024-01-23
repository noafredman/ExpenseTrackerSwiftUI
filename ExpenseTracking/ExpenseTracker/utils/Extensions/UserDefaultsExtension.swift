//
//  UserDefaultsExtension.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import Foundation

extension UserDefaults {
    func set(_ object: Any?, forKey key: UserDefaultsKeys) {
        set(object, forKey: key.rawValue)
    }
}
