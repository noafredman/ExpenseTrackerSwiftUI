//
//  ProfileView.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import SwiftUI

struct ProfileView<T: ProfileViewModelProtocol>: View {
    @ObservedObject var viewModel: T
    @State var isPresented = false
    
    var body: some View {
        
        VStack(spacing: 50) {
            VStack {
                HStack {
                    Text("Total Expense Items:")
                        .font(HelveticaFontsEnum.regular(size: 18).font())
                    
                    Spacer()
                    
                    Text(viewModel.totalExpenseItems)
                        .font(HelveticaFontsEnum.bold(size: 18).font())
                        .padding(.trailing, 5)
                }
                
                Divider()
                    .background(Color(.label))
                    .frame(height: 0.5)
            }
            
            VStack {
                HStack {
                    Button("Sign out") {
                        signout()
                    }
                    .font(HelveticaFontsEnum.regular(size: 18).font())
                    .foregroundStyle(Color(.label))
                    
                    Spacer()
                }
                
                Divider()
                    .background(Color(.label))
                    .frame(height: 0.5)
            }
        }
        .padding(.horizontal, 20)
        .navigationDestination(isPresented: $isPresented) {
            LoginView(viewModel: LoginViewModel(dataManager: DataManager.shared))
                .navigationBarBackButtonHidden()
        }
        .onAppear() {
            viewModel.refreshData()
        }
    }
    
    private func signout() {
        viewModel.logout()
        isPresented = true
    }
}

#Preview {
    ProfileView(viewModel: ProfileViewModel(dataManager: DataManager.shared)
    )
}

