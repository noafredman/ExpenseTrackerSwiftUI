//
//  LoginView.swift
//  ExpenseTracker
//
//  Created by Noa Fredman.
//

import SwiftUI
import Combine

struct LoginView<T: LoginViewModelProtocol>: View {
    private enum Field: Int, Hashable {
        case username
    }
    
    private var viewModel: T
    @State private var username = ""
    @State private var error: InvalidNameError?
    @State private var isShowingDetailView = false
    @State private var isSubmitDisabled = true
    @State private var errorOpacity = 0.0
    @State private var isPresented = false
    @FocusState private var focusedField: Field?
    
    private let searchTextPublisher = PassthroughSubject<String, Never>()
    
    init(viewModel: T) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                TextField(
                    "",
                    text: $username,
                    prompt: Text("Enter Name, e.g: John Doe").foregroundStyle(.gray.opacity(0.5))
                )
                .foregroundStyle(.black)
                .focused($focusedField, equals: .username)
                .font(HelveticaFontsEnum.regular(size: 16).font())
                .onChange(of: username, initial: false) {
                    searchTextPublisher.send(username)
                }
                .onReceive(
                    searchTextPublisher
                        .debounce(for: .seconds(0.35), scheduler: DispatchQueue.main)
                ) { debouncedSearchText in
                    if isValidUsername() {
                        withAnimation(.linear(duration: 0.1)) {
                            resetError()
                            isSubmitDisabled = false
                        }
                    } else {
                        withAnimation(.linear(duration: 0.1)) {
                            isSubmitDisabled = true
                        }
                    }
                }
                .onSubmit {
                    submit()
                }
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .frame(height: 55)
                
                .overlay( /// apply a rounded border
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                            Color(cgColor: 
                                    CGColor(
                                        red: 0.357,
                                        green: 0.345,
                                        blue: 0.678,
                                        alpha: 1
                                    )
                            ),
                            lineWidth: 1
                        )
                    
                )
                .background(
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .shadow(color: Color(cgColor: CGColor(red: 0, green: 0, blue: 0, alpha: 0.6)), radius: 4, x: 0, y: 4)
                    
                )
                
            }.padding(.horizontal, 50)
            
            Text(error?.message() ?? "")
                .frame(height: 100, alignment: .top)
                .foregroundStyle(Color.red)
                .padding(.horizontal, 5)
                .lineLimit(2)
                .opacity(errorOpacity)
            
            Spacer()
            
            SubmitButton(delegate: self, text: "Login", isDisabled: $isSubmitDisabled)
                .navigationDestination(isPresented: $isPresented, destination: {
                    MainTabView(username: username)
                })
            
            Spacer().frame(height: 40)
        }
        .onAppear() {
            self.focusedField = .username
        }
    }
    
    func login() {
        do {
            try viewModel.didLogin(name: username)
            isPresented = true
        } catch {
            
        }
    }
    
    func isValidUsername() -> Bool {
        do {
            try viewModel.isUsernameValid(username)
            return true
        } catch {
            if let error = error as? InvalidNameError {
                handleError(error)
            } else {
                // regex error
            }
            return false
        }
    }
    
    private func handleError(_ error: InvalidNameError) {
        if case InvalidNameError.nameIsEmpty = error {
            withAnimation(.linear(duration: 0.2)) {
                errorOpacity = 0
            }
        } else if case self.error = error {
            // do nothing -> will show the same error text
        } else {
            self.error = error
            if errorOpacity == 1 {
                withAnimation(.linear(duration: 0.2)) {
                    errorOpacity = 0.5
                } completion: {
                    withAnimation(.linear(duration: 0.2)) {
                        errorOpacity = 1
                    }
                }
            } else {
                withAnimation(.linear(duration: 0.2)) {
                    errorOpacity = 1
                }
            }
        }
    }
    
    private func resetError() {
        error = nil
        errorOpacity = 0
    }
    
}

extension LoginView: SubmitButtonDelegate {
    func submit() {
        login()
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel(dataManager: DataManager.shared))
}

