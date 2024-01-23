//
//  MainTabView.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import SwiftUI

struct MainTabView: View {
    
    private enum Tabs: Hashable {
        case home, profile
    }
    
    private var username: String
    private let homeVM = HomeViewModel(dataManager: DataManager.shared)
    private let profileVM = ProfileViewModel(dataManager: DataManager.shared)
    @State private var selectedTab = Tabs.home
    @State private var isCreateExpensePresented = false
    @State private var shouldSaveChanges = false
    private var formType: FormType = .createExpense
    @State private var filterBy: FilteredByFormSent = .filter(date: nil, expense: nil)

    init(username: String) {
        self.username = username
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(username: username, viewModel: homeVM, filterBy: $filterBy)
                    .tabItem { Text("Home") }
                    .tag(Tabs.home)
                
                ProfileView(viewModel: profileVM)
                    .tabItem { Text("Profile") }
                    .tag(Tabs.profile)
            }
            .onAppear() {
                setup()
            }
            
            VStack {
                Spacer()
                
                Button(
                    action: { plusClicked() },
                    label: { Images.plus }
                )
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .padding(.bottom, 20)
                .sheet(isPresented: $isCreateExpensePresented) {
                    switch selectedTab {
                    case .home:
                        if case .none = filterBy {
                            homeVM.updateData(for: .none)
                        }
                        
                    case .profile:
                        profileVM.refreshData()
                    }
                } content: {
                    ExpenseFormView(
                        viewModel: ExpenseFormViewModel(dataManager: DataManager.shared),
                        filterBy: $filterBy,
                        submitButtonText: "Create",
                        formType: formType,
                        titleText: "Create Expense"
                    )
                }
                
            }
        }
        .navigationBarBackButtonHidden()
        .navigationTitle(username)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    //MARK: - Private methods
    
    private func setup() {
        UITabBar.appearance().isHidden = false
        let appearance = UITabBarAppearance()
        appearance.shadowColor = .black
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.412, green: 0.412, blue: 0.412, alpha: 1), .font: HelveticaFontsEnum.regular(size: 16).uiFont() as Any] // unselected tab
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.271, green: 0.369, blue: 1, alpha: 1), .font: HelveticaFontsEnum.bold(size: 16).uiFont() as Any]
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func plusClicked() {
        isCreateExpensePresented = true
    }
}

#Preview {
    MainTabView(username: "Testing name")
}
