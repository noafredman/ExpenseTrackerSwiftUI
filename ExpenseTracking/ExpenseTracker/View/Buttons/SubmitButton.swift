//
//  SwiftUIView.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import SwiftUI

protocol SubmitButtonDelegate {
    func submit()
}

struct SubmitButton: View {
    private var delegate: SubmitButtonDelegate?
    private var text: String = ""
    @Binding private var isDisabled: Bool
    
    init(delegate: SubmitButtonDelegate? = nil, text: String, isDisabled: Binding<Bool>) {
        self.delegate = delegate
        self.text = text
        self._isDisabled = isDisabled
    }
    
    var body: some View {
        Button(text) {
            delegate?.submit()
        }
        .frame(width: 150, height: 44, alignment: .center)
        .font(HelveticaFontsEnum.bold(size: 16).font())
        .foregroundStyle(Color.white)
        .background(Color(uiColor: UIColor(red: 0.357, green: 0.345, blue: 0.678, alpha: isDisabled ? 0.5: 1)))
        .disabled(isDisabled)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}

#Preview {
    struct Del: SubmitButtonDelegate {
        func submit() {
            print("submit clicked!")
        }
    }
    return SubmitButton(delegate: Del(), text: "submit", isDisabled: .constant(false))
}
