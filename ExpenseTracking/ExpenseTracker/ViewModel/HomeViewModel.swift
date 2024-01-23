//
//  HomeViewModel.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import Foundation
import Combine

protocol HomeViewModelProtocol: ObservableObject {
    var amount: String { get }
    var expenseClusterList: [ExpenseCluster] { get }
    var filterBy: FilteredByFormSent { get }
    var didDeleteInfo: Bool { get }
    func updateData(for type: HomeViewModel.UpdateDataType)
    func removedExpense(expenseClusterId: UUID, expenseId: UUID) throws
}

final class HomeViewModel: HomeViewModelProtocol {
    
    enum UpdateDataType: Equatable {
        case filter(date: Date?, expense: Expense?)
        case removedInfo
        case none
        
        static func ==(lhs: UpdateDataType, rhs: UpdateDataType) -> Bool {
            switch (lhs, rhs) {
            case (UpdateDataType.none , UpdateDataType.none), (UpdateDataType.removedInfo , UpdateDataType.removedInfo):
                return true
            case let (UpdateDataType.filter(date1, expense1), UpdateDataType.filter(date2, expense2)):
                return date1 == date2 && expense1 == expense2
            default:
                return false
            }
        }
    }
    
    enum HomeViewModelError: Error {
        case expenseNotFoundError
        case expenseClusterNotFoundError
        case userInfoCorruptDataError
    }
    
    @Published var amount = "\(Locale.current.currencySymbol ?? "")0"
    @Published var expenseClusterList = [ExpenseCluster]()
    @Published var filterBy: FilteredByFormSent = .none
    
    let dataManager: DataManagerProtocol!
    var didDeleteInfo = false
    
    init(dataManager: DataManagerProtocol) {
        self.dataManager = dataManager
        updateData(for: .none)
    }
    
    func updateData(for type: UpdateDataType) {
        guard let expenseClusters = try? dataManager.getExpenseClusters() else {
            return
        }
        switch type {
            
        case .filter(date: let date, expense: let expense):
            didDeleteInfo = false
            expenseClusterList = filterExpenses(date: date, expense: expense, expenseClusters: expenseClusters)
            filterBy = .filter(date: date, expense: expense)
            
        case .none:
            didDeleteInfo = false
            expenseClusterList = expenseClusters
            filterBy = .none
            
        case .removedInfo:
            didDeleteInfo = true
            expenseClusterList = expenseClusters
            filterBy = .none
        }
        
        amount = (Locale.current.currencySymbol ?? "") + (expenseClusterList.reduce(0) {
            $0 + $1.totalAmount()
        }.toStringWithFractionDigits() ?? "")
    }
    
    func removedExpense(expenseClusterId: UUID, expenseId: UUID) throws {
        guard let expenseClusters = try? dataManager.getExpenseClusters() else {
            throw DataManager.DataManagerError.UserInfoError.couldNotFindUserForCurrentUserId
        }
        guard let expenseClusterOfSelectedExpense = expenseClusters.first(where: {
            $0.id == expenseClusterId
        }) else {
            throw HomeViewModelError.expenseClusterNotFoundError
        }
        var indexToRemoveInfoAt = -1
        for (index, expense) in expenseClusterOfSelectedExpense.expenses.enumerated() {
            if expense.id == expenseId {
                indexToRemoveInfoAt = index
                break
            }
        }
        guard indexToRemoveInfoAt >= 0 else {
            // expense to delete not found
            throw HomeViewModelError.expenseNotFoundError
        }
        
        guard var decodedUsersInfo = try? dataManager.getAllUsersInfoArray(),
              let userInfoAndIndex = try? getUserInfoAndIndex(decodedUsersInfo: decodedUsersInfo),
              var userInfo = userInfoAndIndex.userInfo else {
            throw HomeViewModelError.userInfoCorruptDataError
        }
        let userIndex = userInfoAndIndex.userIndex
        for (index, expenseCluster) in userInfo.expenseCluster.enumerated() {
            if Calendar.current.isDate(expenseCluster.date, equalTo: expenseClusterOfSelectedExpense.date, toGranularity: .day) {
                
                userInfo.expenseCluster[index].expenses.remove(at: indexToRemoveInfoAt)
                if userInfo.expenseCluster[index].expenses.isEmpty {
                    userInfo.expenseCluster.remove(at: index)
                }
                break
            }
        }
        
        decodedUsersInfo[userIndex] = userInfo
        if let encoded = try? decodedUsersInfo.encode() {
            dataManager.setUserInfo(encoded)
        }
        updateData(for: .removedInfo)
    }
    
    private func getUserInfoAndIndex(decodedUsersInfo: [UserInfo]) throws -> (userInfo: UserInfo?, userIndex: Int) {
        var userIndex = 0
        var userInfo: UserInfo? = nil
        let currentUserId = try dataManager.getCurrentUserId()
        for (index, infoItem) in decodedUsersInfo.enumerated() {
            if infoItem.id == currentUserId {
                userInfo = infoItem
                userIndex = index
                break
            }
        }
        return (userInfo, userIndex)
    }
    
    private func filterExpenses(date: Date?, expense: Expense?, expenseClusters: [ExpenseCluster]) -> [ExpenseCluster] {
        var expenseClustersFiltered = expenseClusters
        if let date {
            expenseClustersFiltered = expenseClustersFiltered.filter({
                Calendar.current.isDate($0.date, equalTo: date, toGranularity: .day)
            })
        }
        if let expense {
            if expense.amount > 0 {
                expenseClustersFiltered = expenseClustersFiltered.filter({
                    $0.expenses.contains(where: { infoItem in
                        infoItem.amount == expense.amount
                    })
                })
                for index in expenseClustersFiltered.indices {
                    expenseClustersFiltered[index].expenses = expenseClustersFiltered[index].expenses.filter({ infoItem in
                        infoItem.amount == expense.amount
                    }).compactMap({ $0 })
                }
            }
            if expense.title.isEmpty == false {
                expenseClustersFiltered = expenseClustersFiltered.filter({
                    $0.expenses.contains(where: { infoItem in
                        infoItem.title == expense.title
                    })
                })
                for index in expenseClustersFiltered.indices {
                    expenseClustersFiltered[index].expenses = expenseClustersFiltered[index].expenses.filter({ infoItem in
                        infoItem.title == expense.title
                    }).compactMap({ $0 })
                }
            }
        }
        return expenseClustersFiltered
    }
    
}
