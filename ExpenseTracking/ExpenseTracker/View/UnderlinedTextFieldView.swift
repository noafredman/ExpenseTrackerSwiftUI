//
//  UnderlinedTextFieldView.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import SwiftUI

struct UnderlinedTextFieldView: View {

    @Binding private var text: String
    private let promptText: String
    private let keyboardType: UIKeyboardType
    
    init(text: Binding<String>, promptText: String = "", keyboardType: UIKeyboardType = .default) {
        self._text = text
        self.promptText = promptText
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        VStack {
            TextField(
                "",
                text: $text,
                prompt: Text(promptText).foregroundStyle(.gray.opacity(0.5))
            )
            .font(HelveticaFontsEnum.regular(size: 16).font())
            .keyboardType(keyboardType)
            
            Divider()
                .background(Color.gray)
                .frame(height: 0.5)
        }
    }
}

#Preview {
    UnderlinedTextFieldView(text: .constant(""), promptText: "70")
}
