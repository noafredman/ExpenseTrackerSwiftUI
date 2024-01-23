//
//  FilteredByButton.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import SwiftUI

struct FilteredByButton: View {
    var buttonText: String
    var action: () -> ()
    
    var body: some View {
        RoundedSmallButtonWithImage(
            image: Images.xmark,
            buttonText: buttonText,
            font: HelveticaFontsEnum.regular(size: 14).font(),
            backgroundColorName: "btnLightGray",
            action: action
        )
    }
}

#Preview {
    FilteredByButton(buttonText: "filter", action: {})
}
