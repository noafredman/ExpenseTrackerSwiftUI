//
//  ProfileViewModel.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import Foundation
import Combine

protocol ProfileViewModelProtocol: ObservableObject {
    var totalExpenseItems: String { get }
    func refreshData()
    func logout()
}

final class ProfileViewModel: ProfileViewModelProtocol {
    @Published var totalExpenseItems: String = "0"
    var dataManager: DataManagerProtocol!
    
    init(dataManager: DataManagerProtocol) {
        self.dataManager = dataManager
        refreshData()
    }
 
    func refreshData() {
        totalExpenseItems = ((try? dataManager.getExpenseClusters().reduce(0) {
            $0 + $1.expenses.count
        }) ?? 0).description
    }
    
    func logout() {
        dataManager.handleLogout()
    }
}
