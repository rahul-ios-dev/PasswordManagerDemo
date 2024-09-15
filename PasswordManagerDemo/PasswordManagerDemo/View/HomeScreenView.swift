//
//  HomeScreenView.swift
//  PasswordManagerDemo
//
//  Created by Rahul Acharya on 15/09/24.
//

import SwiftUI
import CoreData

struct HomeScreenView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var accountList: [AccountModel] = []
    @State private var showingPasswordDetailsBottomSheet = false
    @State private var showingAddNewPasswordBottomSheet = false
    @State private var selectedItems: AccountModel? = nil // Store the selected item
    
    var body: some View {
        VStack {
            // Title Section
            HeaderView(title: "Password Manager")
            
            // Divider
            DividerView()
            
            // Account List Section
            ScrollView(showsIndicators: false) {
                ForEach(accountList) { account in
                    AccountCell(account: account.userName) {
                        selectedItems = account
                        showingPasswordDetailsBottomSheet = true
                    }
                }
            }
            
            // Floating Button
            AddPasswordButton {
                selectedItems = nil
                showingAddNewPasswordBottomSheet = true
            }
        }
        .background(Color.gray.opacity(0.1))
        .onAppear {
            fetchAccountsFromCoreData() // Fetch accounts when the view appears
        }
        .sheet(isPresented: $showingAddNewPasswordBottomSheet) {
            AddNewPasswordSheet(saveAction: {
                fetchAccountsFromCoreData()
            }, accountModel: selectedItems)
            .presentationDetents([.fraction(0.5)])
        }
        .sheet(isPresented: $showingPasswordDetailsBottomSheet) {
            if let selectedItem = selectedItems {
                ShowPasswordSheets(model: selectedItem, onDelete: { account in
                    deleteAccountFromCoreData(account: account)
                    showingPasswordDetailsBottomSheet = false
                }, onEdit: { account in
                    showingPasswordDetailsBottomSheet = false
                    selectedItems = account
                    showingAddNewPasswordBottomSheet = true
                })
                .presentationDetents([.fraction(0.5)])
            }
        }
    }
    
    
    // Fetch accounts from Core Data
    private func fetchAccountsFromCoreData() {
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest() // Assuming 'Account' is the entity name
        
        do {
            let fetchedAccounts = try viewContext.fetch(fetchRequest)
            accountList = fetchedAccounts.map { account in
                AccountModel(id: account.id ?? UUID(),
                             userName: account.name ?? "",
                             email: account.email ?? "",
                             pass: account.password ?? "")
            }
        } catch {
            print("Failed to fetch accounts: \(error.localizedDescription)")
        }
    }
    
    private func deleteAccountFromCoreData(account: AccountModel) {
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", account.id as CVarArg)
        
        do {
            let accounts = try viewContext.fetch(fetchRequest)
            if let accountToDelete = accounts.first {
                viewContext.delete(accountToDelete)
                try viewContext.save()
                HelperClass.printDocumentsDirectoryPath()
                fetchAccountsFromCoreData() // Refresh the account list
            }
        } catch {
            print("Failed to delete account: \(error.localizedDescription)")
        }
    }

}

// MARK: - Sheetssssssss
struct AddNewPasswordSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var user: String
    @State private var email: String
    @State private var password: String
    @State private var showAlert = false
    @State private var alertMessage = ""

    var saveAction: () -> Void
    var accountModel: AccountModel? // Optional account model for editing
    
    init(saveAction: @escaping () -> Void, accountModel: AccountModel? = nil) {
        self.saveAction = saveAction
        self.accountModel = accountModel
        _user = State(initialValue: accountModel?.userName ?? "")
        _email = State(initialValue: accountModel?.email ?? "")
        _password = State(initialValue: accountModel?.pass ?? "")
    }
    
    var body: some View {
        VStack {
            CapsuleView()
            
            TextField("Account Name", text: $user)
                .textFieldStyle(.roundedBorder)
                .padding()
                .autocorrectionDisabled()
            
            TextField("Username/ Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .padding()
                .autocorrectionDisabled()
                .autocapitalization(.none)
            
            TextField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding()
                .autocorrectionDisabled()
            
            PrimaryButton(title: accountModel == nil ? "Add New Account" : "Save Changes", backgroundColor: .black) {
                if validateFields() {
                    if HelperClass.isValidEmail(email) {
                    if let model = accountModel {
                        // Update existing account
                        updateAccountInCoreData(model: model, user: user, email: email, password: password)
                    } else {
                        // Add new account
                        saveAccountToCoreData(user: user, email: email, password: password)
                    }
                        saveAction()
                        presentationMode.wrappedValue.dismiss()
                    }else {
                        alertMessage = "Invalid email format."
                        showAlert = true
                    }
                } else {
                    alertMessage = "All fields must be filled out."
                    showAlert = true
                    print("All fields must be filled out.")
                }
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func validateFields() -> Bool {
        return !user.isEmpty && !email.isEmpty && !password.isEmpty
    }
    
    private func saveAccountToCoreData(user: String, email: String, password: String) {
        let newAccount = Account(context: viewContext)
        newAccount.id = UUID()
        newAccount.name = user
        newAccount.email = email
        newAccount.password = password
        
        do {
            try viewContext.save()
            print("Account saved successfully!")
        } catch {
            print("Failed to save account: \(error.localizedDescription)")
        }
    }
    
    private func updateAccountInCoreData(model: AccountModel, user: String, email: String, password: String) {
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", model.id as CVarArg)
        
        do {
            let accounts = try viewContext.fetch(fetchRequest)
            if let accountToUpdate = accounts.first {
                accountToUpdate.name = user
                accountToUpdate.email = email
                accountToUpdate.password = password
                try viewContext.save()
                print("Account updated successfully!")
            }
        } catch {
            print("Failed to update account: \(error.localizedDescription)")
        }
    }
}

struct ShowPasswordSheets: View {
    var model: AccountModel
    var onDelete: (AccountModel) -> Void
    var onEdit: (AccountModel) -> Void

    @State private var showingDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading) {
            CapsuleView()
            
            Spacer()
            Text("Account Details")
                .font(.headline)
                .bold()
                .foregroundStyle(.link)
            
            Spacer()
            InfoSectionView(title: "Account Type", content: model.userName)
            
            Spacer()
            InfoSectionView(title: "Username / Email", content: model.email)
            
            Spacer()
            Text("Password")
                .font(.caption)
                .foregroundStyle(.gray)
            PasswordSectionView(model: model)
            
            Spacer()
            // Buttons for Edit and Delete actions
            HStack {
                PrimaryButton(title: "Edit", backgroundColor: .black) {
                    onEdit(model) // Trigger edit action
                }
                
                PrimaryButton(title: "Delete", backgroundColor: .red) {
                    showingDeleteAlert = true // Show the delete confirmation alert
                }
                .background(Capsule().fill(.red)) // Customize Delete button color
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Confirm Deletion"),
                message: Text("Are you sure you want to delete this account?"),
                primaryButton: .destructive(Text("Delete")) {
                    onDelete(model) // Trigger delete action
                },
                secondaryButton: .cancel()
            )
        }
    }
}



struct PasswordSectionView: View {
    var model: AccountModel
    
    // State to track whether the password is secured or visible
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        HStack {
            // Conditional rendering based on whether the password is visible or not
            if isPasswordVisible {
                // Show password as plain text when visible
                TextField("", text: .constant(model.pass))
                    .font(.headline)
                    .foregroundColor(.black)
                    .disabled(true) // Make the text field non-editable
            } else {
                // SecureField to hide password by default
                SecureField("", text: .constant(model.pass))
                    .font(.headline)
                    .foregroundColor(.black)
                    .disabled(true) // Make the text field non-editable
            }

            Spacer()
            
            // Toggle button to show or hide password
            Button(action: {
                isPasswordVisible.toggle() // Toggle password visibility
            }) {
                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                    .font(.caption)
                    .foregroundColor(.black) // Optional: Add color for better visibility
            }
        }
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    HomeScreenView()
}
