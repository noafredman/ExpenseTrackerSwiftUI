//
//  ViewExtension.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import SwiftUI

extension View {
    func hideKeyboardWhenTappedAround() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
    
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
