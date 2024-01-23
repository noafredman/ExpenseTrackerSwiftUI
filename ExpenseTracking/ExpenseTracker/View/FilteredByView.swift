//
//  FilteredByView.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import SwiftUI

struct FilteredByView: View {
    var shouldShowFilteredBy: Bool = false
    @Binding var filterBy: FilteredByFormSent
    private var date: Date? = nil
    private var expense: Expense? = nil
    
    init(filterBy:  Binding<FilteredByFormSent>) {
        self._filterBy = filterBy
        
        switch filterBy.wrappedValue  {
        case .filter(let date, let expense):
            self.date = date
            self.expense = expense
            self.shouldShowFilteredBy = true

        case .none:
            self.shouldShowFilteredBy = false
        }
    }
    
    var body: some View {
        HStack {
            if shouldShowFilteredBy == true {
                if let _ = date {
                    // date is not nil -> create a filter button for date
                    FilteredByButton(buttonText: "Date") {
                        // remove the filter button once tapped
                        shouldRemoveDateFilter(expense: expense)
                    }
                } else {
                    // date is nil -> there's no filter button for date
                }
                
                if let expense {
                    // amount and/or title updated
                    if expense.amount != 0 {
                        FilteredByButton(buttonText: "Amount") {
                            shouldRemoveAmountFilter(date: date, expense: expense)
                        }
                    }
                    if expense.title.isEmpty == false {
                        FilteredByButton(buttonText: "Title") {
                            shouldRemoveTitleFilter(date: date, expense: expense)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func shouldRemoveDateFilter(expense: Expense?) {
        filterBy = .filter(date: nil, expense: expense)
    }
    
    private func shouldRemoveAmountFilter(date: Date?, expense: Expense) {
        let newExpense = Expense(id: UUID(), title: expense.title, amount: 0)
        filterBy = .filter(date: date, expense: newExpense)
    }
    
    private func shouldRemoveTitleFilter(date: Date?, expense: Expense) {
        let newExpense = Expense(id: UUID(), title: "", amount: expense.amount)
        filterBy = .filter(date: date, expense: newExpense)
    }
}

#Preview {
    FilteredByView( filterBy: .constant(.filter(date: Date(), expense: nil)))
}
