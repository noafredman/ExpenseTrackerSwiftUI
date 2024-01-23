//
//  ProfileViewModelTests.swift
//  ExpenseTracking
//
//  Created by Noa Fredman on 18/01/2024.
//

import XCTest
@testable import ExpenseTracking

final class ProfileViewModelTests: XCTestCase {
    private var profileViewModel: (any ProfileViewModelProtocol)!
    private var mockDataManager: MockDataManager!
    
    override func setUp() {
        super.setUp()
        let userDefaults = UserDefaults(suiteName: #file)!
        userDefaults.removePersistentDomain(forName: #file)
        mockDataManager = MockDataManager(userDefaults: userDefaults)
        mockDataManager.getExpenseClustersCalled = { // needed because the init of ProfileViewModel calls getExpenseClusters
            return []
        }
        profileViewModel = ProfileViewModel(dataManager: mockDataManager)
        
    }
    
    func testRefreshData_expectNoIssue() {
        let expense = createExpense()
        let expenseCluster = ExpenseCluster(
            id: UUID(),
            date: Date.today,
            expenses: [expense]
        )
        
        let getExpenseClustersCalledExpectation = expectation(description: "getExpenseClustersCalled expectation")
        mockDataManager.getExpenseClustersCalled = {
            getExpenseClustersCalledExpectation.fulfill()
            return [expenseCluster]
        }
        
        profileViewModel.refreshData()
        XCTAssertEqual(profileViewModel.totalExpenseItems, "1")
        
        wait(for: [getExpenseClustersCalledExpectation], timeout: 0.01)
    }
    
    func testLogout_expectNoIssue() {

        let handleLogoutCalledExpectation = expectation(description: "handleLogoutCalled expectation")
        mockDataManager.handleLogoutCalled = {
            handleLogoutCalledExpectation.fulfill()
        }
        
        profileViewModel.logout()
        
        wait(for: [handleLogoutCalledExpectation], timeout: 0.01)
    }
    
    private func createExpense() -> Expense {
        Expense(
            id: UUID(),
            title: Lorem.title,
            amount: Double.random(in: 1...1_000)
        )
    }
}
