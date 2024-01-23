//
//  ExpenseCell.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import SwiftUI

struct ExpenseCell: View {
    @Binding var expense: Expense
    @Binding var shouldHideSeperator: Bool

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(expense.title) // title
                    .frame(maxWidth: 195, alignment: .leading)
                    .padding(EdgeInsets.init(top: 0, leading: 16, bottom: 0, trailing: 20))
                    .lineLimit(2)
                
                Text((Locale.current.currencySymbol ?? "") + (expense.amount.toStringWithFractionDigits() ?? "")) // amount
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                    .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 16))
            }
            Spacer()
            
            if shouldHideSeperator == false {
                Divider()
                    .background(Color(.label))
                    .frame(height: 0.5)
                    .listRowInsets(EdgeInsets())
            }
        }
    }
}

struct DesignView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseCell(expense: .constant(Expense(id: UUID(), title: "car", amount: 120_000)), shouldHideSeperator: .constant(false))
    }
}
