//
//  ExpenseFormView.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import SwiftUI
import Combine

enum FormType {
    case createExpense
    case editExpense(expenseClusterId: UUID, expenseId: UUID)
    case filter(date: Date?, expense: Expense?)
}

enum FilteredByFormSent: Equatable {
    case filter(date: Date?, expense: Expense?)
    case none
}

struct ExpenseFormView<T: ExpenseFormViewModelProtocol>: View {
    private enum Field: Int, Hashable {
        case title
        case amount
    }
    
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var oldAmount: String = ""
    @State private var newAmount: String = ""
    @State private var date: Date?
    @State private var hidenDate: Date = Date()
    @State private var showDate: Bool = false
    @State private var isDisabled = false
    @FocusState private var focusedField: Field?
    @ObservedObject var viewModel: T
    @Binding private var filterBy: FilteredByFormSent

    private var submitButtonText: String
    private var formType: FormType
    private let dataManager = DataManager.shared
    private var titleText: String
    
    init(
        viewModel: T,
        filterBy: Binding<FilteredByFormSent> = .constant(.filter(date: nil, expense: nil)),
        submitButtonText: String,
        formType: FormType,
        titleText: String
    ) {
        self.viewModel = viewModel
        self._filterBy = filterBy
        self.submitButtonText = submitButtonText
        self.formType = formType
        self.titleText = titleText
        hideKeyboardWhenTappedAround()
    }
    
    var body: some View {
        
        VStack {
            HStack {
                if case .filter = formType  {
                    Button("clean") {
                        cleanClicked()
                    }
                    .foregroundStyle(.blue)
                    .frame(height: 40, alignment: .bottomTrailing)
                }
                Spacer()
                
                XDismissButton()
            }
            .padding(.horizontal, 16)
            VStack(spacing: 50) {
                Text(titleText)
                    .font(HelveticaFontsEnum.regular(size: 18).font())
                    .lineLimit(1)
                    .padding(.bottom, 10)
                
                UnderlinedTextFieldView(text: $title, promptText: ("Title: up to 40 characters"))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .title)
                    .onSubmit {
                        focusedField = .amount
                    }
                    .onReceive(Just(title)) { char in
                        limitTitleText(&title, 40)
                    }
                
                UnderlinedTextFieldView(text: $newAmount, promptText: ("Amount: up to 1B"), keyboardType: .decimalPad)
                    .focused($focusedField, equals: .amount)
                    .onReceive(Just(newAmount)) { char in
                        limitAmountText(&newAmount, &oldAmount)
                    }
                    .onChange(of: focusedField, initial: false) { isFocused, newFocuseField  in
                        if isFocused == .amount && newFocuseField != .amount {
                            showAmountWithCorrency()
                        }
                    }
                
                VStack {
                    DatePickerNullable(selection: $date)
                    .font(HelveticaFontsEnum.regular(size: 16).font())
                    .simultaneousGesture(TapGesture().onEnded({
                        endEditing()
                    }))
                    
                    Divider()
                        .background(Color.gray)
                        .frame(height: 0.5)
                }
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            
            Spacer()
            
            if case .filter = formType {
                SubmitButton(delegate: self, text: submitButtonText, isDisabled:  .constant(false))
            }  else {
                SubmitButton(delegate: self, text: submitButtonText, isDisabled: .constant($title.wrappedValue.isEmpty != false || $newAmount.wrappedValue.isEmpty != false || date == nil))
            }
                
            Spacer()
                .frame(height: 40)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboardWhenTappedAround()
            if focusedField == .amount {
                showAmountWithCorrency()
            }
        }
        .onAppear() {
            setup()
        }
    }
}

// MARK: - Private methods
extension ExpenseFormView {
    private func setup() {
        focusedField = .title
        
        switch formType {
        case .createExpense:
            break
            
        case .filter:
            switch filterBy {
                
            case .filter(date: let date, expense: let expense):
                title = expense?.title ?? ""
                newAmount = expense?.amount == 0 ? "" : expense?.amount.toStringWithFractionDigits() ?? ""
                self.date = date
            case .none:
                break
            }
            
        case let .editExpense(expenseClusterId: expenseClusterId, expenseId: expenseId):
            // show relevant info
            guard let expenseCluster = try? dataManager.getExpenseClusters().first(where: {
                $0.id == expenseClusterId
            }) else {
                return
            }
            guard let expense = expenseCluster.expenses.first(where: {
                $0.id == expenseId
            }) else {
                return
            }
            title = expense.title
            newAmount = expense.amount == 0 ? "" : expense.amount.toStringWithFractionDigits() ?? ""
            date = expenseCluster.date
            isDisabled = false
        }
    }
    
    private func limitTitleText(_ title: inout String, _ limit: Int) {
        if (title.count > limit) {
            title = String(title.prefix(limit))
        }
    }
    
    private func limitAmountText(_ newAmount: inout String, _ oldAmount: inout String) {
        let newText = newAmount
        guard newText.components(separatedBy: ".").count - 1 <= 1,
              let newNumber = newText.toDouble(),
              newNumber < 1_000_000_000 else {
            if newText.toDouble() == nil && newAmount.count < oldAmount.count {
                newAmount = ""
            } else {
                newAmount = oldAmount
            }
            return
        }
        
        let numberOfDecimalDigits: Int
        if let dotIndex = newText.firstIndex(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }
        if numberOfDecimalDigits <= 2 {
            oldAmount = newText // newText is viable
        } else {
            newAmount = oldAmount
        }
    }
    
    private func showAmountWithCorrency() {
        let number = newAmount.toDoubleString()
        newAmount = number.isEmpty ? "" : (Locale.current.currencySymbol ?? "") + number
        oldAmount = newAmount
    }
    
    private func cleanClicked() {
        title = ""
        newAmount = ""
        date = nil
        oldAmount = ""
    }
}

extension ExpenseFormView: SubmitButtonDelegate {
    func submit() {
        let title = title
        let amount = newAmount
        let date = date
        
        switch formType {
            
        case .createExpense:
            guard title.isEmpty == false, title.starts(with: " ") == false,
                  amount.isEmpty == false,
                  let amountNumber = amount.toDouble(),
                  let date
            else {
                return
            }
            viewModel.createClicked(
                date: date,
                expense: Expense(id: UUID(),
                                 title: title,
                                 amount: amountNumber),
                newExpenseClusterId: UUID()
            )
            dismiss()
            filterBy = .none
            
        case let .editExpense(expenseClusterId: expenseClusterId, expenseId: expenseId):
            guard title.isEmpty == false,
                  amount.isEmpty == false,
                  let amountNumber = amount.toDouble(),
                    let date
            else {
                return
            }
            viewModel.saveEditedExpense(
                expenseClusterId: expenseClusterId,
                date: date,
                expense: Expense(id: expenseId,
                                 title: title,
                                 amount: amountNumber)
            )
            dismiss()
            filterBy = .none
            
        case .filter:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            dismiss()
            filterBy = .filter(
                date: date,
                expense: Expense(
                    id: UUID(),
                    title: title,
                    amount: amount.toDouble() ?? 0
                )
            )
        }
    }
}

#Preview {
    return ExpenseFormView(
        viewModel: ExpenseFormViewModel(dataManager: DataManager.shared),
        filterBy: .constant(.filter(date: nil, expense: nil)),
        submitButtonText: "Save",
        formType: .createExpense,
        titleText: "Edit Expense"
    )
}
