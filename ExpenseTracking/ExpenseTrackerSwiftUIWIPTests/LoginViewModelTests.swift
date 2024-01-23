//
//  LoginViewModelTests.swift
//  LoginViewModelTests
//
//  Created by Noa Fredman.
//

import XCTest
@testable import ExpenseTracking

final class LoginViewModelTests: XCTestCase {
    private var loginViewModel: LoginViewModelProtocol!
    private var mockDataManager: MockDataManager!
    
    override func setUp() {
        super.setUp()
        let userDefaults = UserDefaults(suiteName: #file)!
        userDefaults.removePersistentDomain(forName: #file)
        mockDataManager = MockDataManager(userDefaults: userDefaults)
        loginViewModel = LoginViewModel(dataManager: mockDataManager)
    }
    
    func testLoginCreateNewUserIfUserAlreadyExist() {
        let name1 = Lorem.firstName
        let name2 = Lorem.firstName + Lorem.firstName
        mockDataManager.handleLoginCalled = { userInfo in
            XCTAssertNotNil(userInfo)
            XCTAssertEqual(userInfo.name, name1)
        }
        XCTAssertNotNil(try? loginViewModel.didLogin(name: name1))
        
        mockDataManager.handleLoginCalled = { userInfo in
            XCTAssertNotNil(userInfo)
            XCTAssertEqual(userInfo.name, name2)
        }
        XCTAssertNotNil(try? loginViewModel.didLogin(name: name2))
    }
    
    func testIsUsernameValid_expectValid() {
        let name1 = Lorem.firstName
        let name2 = Lorem.firstName + Lorem.firstName
        XCTAssertNotNil(try? loginViewModel.isUsernameValid(name1))
        XCTAssertNotNil(try? loginViewModel.isUsernameValid(name2))
    }
    
    func testIsUsernameValid_expectInalidError_nameMustConsistOnlyLetters() {
        let name1 = Lorem.firstName + "1"
        XCTAssertThrowsError(try loginViewModel.isUsernameValid(name1)) { error in
            XCTAssertEqual(error as! InvalidNameError, InvalidNameError.nameMustConsistOnlyLetters)
        }
        
        let name2 = Lorem.firstName + "!"
        XCTAssertThrowsError(try loginViewModel.isUsernameValid(name2)) { error in
            XCTAssertEqual(error as! InvalidNameError, InvalidNameError.nameMustConsistOnlyLetters)
        }
    }
    
    func testIsUsernameValid_expectInalidError_nameCanHaveUpToTwoWords() {
        let name = "\(Lorem.firstName) \(Lorem.lastName) \(Lorem.lastName)"
        XCTAssertThrowsError(try loginViewModel.isUsernameValid(name)) { error in
            XCTAssertEqual(error as! InvalidNameError, InvalidNameError.nameCanHaveUpToTwoWords)
        }
    }
    
    func testIsUsernameValid_expectInalidError_twoNamesLength() {
        let name1 = Lorem.firstName + " "
        XCTAssertThrowsError(try loginViewModel.isUsernameValid(name1)) { error in
            XCTAssertEqual(error as! InvalidNameError, InvalidNameError.twoNamesLength)
        }
        
        let name2 = "\(Lorem.firstName) aNameWithOverTwentyCharacters"
        XCTAssertThrowsError(try loginViewModel.isUsernameValid(name2)) { error in
            XCTAssertEqual(error as! InvalidNameError, InvalidNameError.twoNamesLength)
        }
        
        let name3 = "aNameWithOverTwentyCharacters \(Lorem.lastName)"
        XCTAssertThrowsError(try loginViewModel.isUsernameValid(name3)) { error in
            XCTAssertEqual(error as! InvalidNameError, InvalidNameError.twoNamesLength)
        }
        
        let name4 = " "
        XCTAssertThrowsError(try loginViewModel.isUsernameValid(name4)) { error in
            XCTAssertEqual(error as! InvalidNameError, InvalidNameError.twoNamesLength)
        }
    }
    
    func testIsUsernameValid_expectInalidError_oneNameLength() {
        let name1 = "aNameWithOverTwentyCharacters"
        XCTAssertThrowsError(try loginViewModel.isUsernameValid(name1)) { error in
            XCTAssertEqual(error as! InvalidNameError, InvalidNameError.oneNameLength)
        }
    }
}
