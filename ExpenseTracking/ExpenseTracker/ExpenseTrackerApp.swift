//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Noa Fredman.
//

import SwiftUI

@main
struct ExpenseTrackerApp: App {
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if let username = DataManager.shared.getCurrentUserName() {
                    // user is logged in - show expense table
                    MainTabView(username: username)
                        .navigationBarBackButtonHidden()
                } else {
                    LoginView(viewModel: LoginViewModel(dataManager: DataManager.shared))
                        .navigationBarBackButtonHidden()
                }
            }
        }
    }
    
}
