//
//  RoundedSmallButtonWithImage.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import SwiftUI

struct RoundedSmallButtonWithImage: View {
    var image: Image
    var buttonText: String
    var font: Font
    var backgroundColorName: String
    var action: () -> ()
    
    var body: some View {
        Button() {
            action()
        } label: {
            
            HStack {
                HStack {
                    image
                        .foregroundStyle(.black)
                    Text(buttonText)
                        .font(font)
                        .foregroundStyle(Color.black)
                }
                .padding(.all, 5)
            }
        }
        .frame(width: 94, height: 28)
        .background(Color(backgroundColorName))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        
    }
}

#Preview {
    RoundedSmallButtonWithImage(image: Image("sliders"), buttonText: "Filters", font: .footnote, backgroundColorName: "btnLightGray", action: {})
}
