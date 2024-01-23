//
//  LoginViewModel.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import Foundation

protocol LoginViewModelProtocol {
    func didLogin(name: String) throws
    func isUsernameValid(_ username: String) throws
}

final class LoginViewModel: LoginViewModelProtocol {
    let dataManager: DataManagerProtocol
    
    init(dataManager: DataManagerProtocol) {
        self.dataManager = dataManager
    }
    
    func didLogin(name: String) throws {
        let userInfo = UserInfo(id: UUID(), name: name)
        try dataManager.handleLogin(userInfo: userInfo)
    }
    
    func isUsernameValid(_ username: String) throws {
        guard !username.isEmpty else {
            throw InvalidNameError.nameIsEmpty
        }
        do {
            let regexNonLetters = try Regex("^(?=[a-zA-Z(\\s)?]*$)(?!.*[.])")
            guard username.contains(regexNonLetters) else {
                throw InvalidNameError.nameMustConsistOnlyLetters
            }
            let regexTwoNames = try Regex("^[a-zA-Z]{1,19}\\s[a-zA-Z]{1,19}$")
            if username.contains(" ") {
                guard username.firstIndex(of: " ") == username.lastIndex(of: " ") else {
                    throw InvalidNameError.nameCanHaveUpToTwoWords
                }
                guard username.contains(regexTwoNames) else {
                    throw InvalidNameError.twoNamesLength
                }
            } else {
                let regexOneName = try Regex("^[a-zA-Z]{1,20}$")

                guard username.contains(regexOneName) else {
                    throw InvalidNameError.oneNameLength
                }
            }

        } catch {
            throw error
        }
    }
}
