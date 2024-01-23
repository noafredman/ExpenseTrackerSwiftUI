//
//  HomeView.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import SwiftUI

struct HomeView<T: HomeViewModelProtocol>: View {
    
    private var username: String
    @ObservedObject private var viewModel: T
    @Binding private var filterBy: FilteredByFormSent
    @State private var formType: FormType = .createExpense
    @State private var totalAmount = "0"
    @State private var shouldHideSeperator = 0
    
    init(
        username: String,
        viewModel: T,
        filterBy: Binding<FilteredByFormSent>
    ) {
        self.username = username
        self.viewModel = viewModel
        self._filterBy = filterBy
    }
    
    var body: some View {
        if viewModel.expenseClusterList.isEmpty, case .none = filterBy {
            Text("You have 0 expenses")
        } else {
            VStack {
                HeaderView(amount: viewModel.amount)
                
                FiltersButton(
                    filterBy: $filterBy,
                    updateData: viewModel.updateData
                )
                
                if case .filter(let date, let expense) = filterBy, date != nil || expense != nil {
                    HStack {
                        FilteredByView(filterBy: $filterBy)
                        .onChange(of: filterBy, initial: true) { isFocused, newFocuseField  in
                            if case .filter(let date, let expense) = filterBy {
                                viewModel.updateData(for: .filter(date: date, expense: expense))
                            }
                        }
                    }
                }
                
                if viewModel.expenseClusterList.isEmpty {
                    Spacer()
                    Text("You have 0 expenses for chosen filters")
                    Spacer()
                } else {
                    ExpenseList(
                        filterBy: $filterBy,
                        expenseClusterList: viewModel.expenseClusterList,
                        updateData: viewModel.updateData,
                        removedExpense: viewModel.removedExpense
                    )
                }
            }
            .onAppear() {
                viewModel.updateData(for: .none)
            }
        }
    }
    
}

// MARK: - Private Views

extension HomeView {
    
    // MARK: HeaderView
    
    private struct HeaderView: View {
        
        private let amount: String
        
        init(amount: String) {
            self.amount = amount
        }
        
        var body: some View {
            HStack {
                Text("Total Expenses:")
                    .font(HelveticaFontsEnum.bold(size: 16).font())
                Text(amount)
                    .font(HelveticaFontsEnum.regular(size: 20).font())
                    .padding(.leading, 15)
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 30, trailing: 0))
        }
        
    }
    
    // MARK: FiltersButton
    
    private struct FiltersButton: View {
        
        @Binding private var filterBy: FilteredByFormSent
        @State private var isFilterPresented = false
        private let updateData: (_ type: HomeViewModel.UpdateDataType) -> ()
        
        init(
            filterBy: Binding<FilteredByFormSent>,
            updateData: @escaping (_: HomeViewModel.UpdateDataType) -> Void
        ) {
            self._filterBy = filterBy
            self.updateData = updateData
        }
        
        var body: some View {
            HStack {
                Spacer()
                RoundedSmallButtonWithImage(
                    image: Image("sliders"),
                    buttonText: "Filters",
                    font: HelveticaFontsEnum.bold(size: 14).font(),
                    backgroundColorName: "btnLightGray"
                ) {
                    isFilterPresented = true
                }
                .padding(.trailing, 10)
                .sheet(isPresented: $isFilterPresented) {
                    if case .filter(let date, let expense) = filterBy {
                        updateData(.filter(date: date, expense: expense))
                    }
                } content:  {
                    filterClicked()
                }
            }
        }
        
        private func filterClicked() -> some View {
            if case let .filter(date, expense) = filterBy, date != nil || expense != nil {
            } else {
                filterBy = .none
            }
            return ExpenseFormView(
                viewModel: ExpenseFormViewModel(dataManager: DataManager.shared),
                filterBy: $filterBy,
                submitButtonText: "Filter",
                formType: .filter(date: nil, expense: nil),
                titleText: "Filter"
            )
            .presentationDetents([.fraction(0.75)])
        }
        
    }
    
    // MARK: ExpenseList
    
    private struct ExpenseList: View {
        
        class ExpenseListState: ObservableObject {
            @Published var expenseClusterId = UUID()
            @Published var expenseId = UUID()
            
            func update(expenseClusterId: UUID, expenseId: UUID) {
                self.expenseClusterId = expenseClusterId
                self.expenseId = expenseId
            }
        }
        
        @ObservedObject private var state = ExpenseListState()
        @State private var isExpenseFormPresented = false
        @Binding private var filterBy: FilteredByFormSent
        
        private let expenseClusterList: [ExpenseCluster]
        private let updateData: (_ type: HomeViewModel.UpdateDataType) -> ()
        private let removedExpense: (_ expenseClusterId: UUID , _ expenseId: UUID) throws -> ()
        
        init(
            filterBy: Binding<FilteredByFormSent>,
            expenseClusterList: [ExpenseCluster],
            updateData: @escaping (_ type: HomeViewModel.UpdateDataType) -> (),
            removedExpense: @escaping (_ expenseClusterId: UUID, _ expenseId: UUID) throws -> ()
        ) {
            self._filterBy = filterBy
            self.expenseClusterList = expenseClusterList
            self.updateData = updateData
            self.removedExpense = removedExpense
        }
        
        var body: some View {
            List {
                ForEach(expenseClusterList, id: \.date) { expenseCluster in
                    Section {
                        Text(expenseCluster.date.toString())
                            .font(HelveticaFontsEnum.regular(size: 17).font())
                            .foregroundStyle(Color.black)
                            .background(Color.clear)
                    }
                    .frame(height: 25)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                    .listRowBackground(Color("Expense Header Color"))
                    .listSectionSeparator(.hidden)
                    
                    ForEach(expenseCluster.expenses, id: \.id) { expense in
                        ExpenseCell(
                            expense: .constant(expense),
                            shouldHideSeperator: .constant(expenseCluster.expenses.firstIndex(
                                where: {$0.id == expense.id}
                            ) == expenseCluster.expenses.count - 1)
                        )
                        .frame(height: 60)
                        .swipeActions {
                            Button("Delete") {
                                deleteExpenseClicked(expenseClusterId: expenseCluster.id, expenseId: expense.id)
                            }
                            .tint(.red)
                            
                            Button("Edit") {
                                editExpenseClicked(expenseClusterId: expenseCluster.id, expenseId: expense.id)
                            }
                            .tint(.green)
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    .listSectionSeparator(.hidden)
                    .listRowSeparator(.hidden)
                }
                
            }
            .sheet(isPresented: $isExpenseFormPresented) {
                // refresh table data only if the edit changes are saved
                if case .none = filterBy {
                    updateData(.none)
                }
            } content: {
                ExpenseFormView(
                    viewModel: ExpenseFormViewModel(dataManager: DataManager.shared),
                    filterBy: $filterBy,
                    submitButtonText: "Save",
                    formType: .editExpense(expenseClusterId: state.expenseClusterId, expenseId: state.expenseId),
                    titleText: "Edit Expense"
                )
            }
            .padding(.top, 15)
            .environment(\.defaultMinListRowHeight, 0)
            .listStyle(PlainListStyle())
            .listSectionSpacing(0)
            .listRowSeparator(.hidden)
            .background(Color.clear)
            .scrollContentBackground(.hidden)
        }
        
        private func editExpenseClicked(expenseClusterId: UUID, expenseId: UUID) {
            state.update(expenseClusterId: expenseClusterId, expenseId: expenseId)
            isExpenseFormPresented = true
        }
        
        private func deleteExpenseClicked(expenseClusterId: UUID, expenseId: UUID) {
            do {
                try removedExpense(expenseClusterId, expenseId)
            } catch {
                print(error)
                return
            }
        }
        
    }
    
}

// MARK: - Preview
#Preview {
    HomeView(
        username: "Testing name",
        viewModel: HomeViewModel(dataManager: DataManager.shared), filterBy: .constant(.none)
    )
}
