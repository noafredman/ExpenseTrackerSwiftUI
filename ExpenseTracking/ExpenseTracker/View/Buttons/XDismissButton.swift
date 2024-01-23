//
//  XDismissButton.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import SwiftUI

struct XDismissButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button() {
            dismiss()
        } label: {
            Images.xmark
        }
        .frame(width: 44,height: 44, alignment: .bottomTrailing)
        .foregroundStyle(Color(.label))
    }
}

#Preview {
    XDismissButton()
}
