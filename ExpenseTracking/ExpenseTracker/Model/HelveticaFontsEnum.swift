//
//  HelveticaFontsEnum.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import SwiftUI

enum HelveticaFontsEnum {
    case regular(size: CGFloat)
    case bold(size: CGFloat)
    
    func font() -> Font {
        switch self {
        case .regular(size: let size), .bold(size: let size):
            return Font.custom(toString(), size: size)
        }
    }
    
    func uiFont() -> UIFont {
        switch self {
        case .regular(size: let size), .bold(size: let size):
            return UIFont(name: toString(), size: size) ?? .systemFont(ofSize: size)
        }
    }
    
    private func toString() -> String {
        switch self {
        case .regular:
            return "Helvetica"
        case .bold:
            return "Helvetica-Bold"
        }
    }
}

