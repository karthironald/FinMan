//
//  FMAddAccount.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/05/21.
//

import SwiftUI

struct FMAddAccountView: View {
    @State var name: String = ""
    @State var comments: String = ""
    @Binding var shouldPresentAddAccountView: Bool
    @State private var alertInfoMessage = ""
    @State private var shouldShowAlert = false
    
    var viewModel: FMAccountListViewModel? = nil
    var accountRowViewModel: FMAccountRowViewModel? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Enter account name", text: $name)
                        .keyboardType(.default)
                }
                Section {
                    ZStack(alignment: .topLeading) {
                        if comments.isEmpty {
                            Text("Enter additional comments(if any)")
                                .foregroundColor(.secondary)
                                .opacity(0.5)
                                .padding([.top, .leading], 5)
                        }
                        TextEditor(text: $comments)
                            .frame(height: 100, alignment: .center)
                    }
                }
            }
            .alert(isPresented: $shouldShowAlert, content: {
                Alert(title: Text(alertInfoMessage), message: nil, dismissButton: Alert.Button.default(Text(kOkay), action: {
                    // Do nothing
                }))
            })
            .navigationBarTitle(Text("Add Account"), displayMode: .inline)
            .navigationBarItems(trailing: saveButtonView())
        }
    }
    
    func saveButtonView() -> some View {
        Button("Save") {
            saveButtonTapped()
        }
        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    func saveButtonTapped() {
        if accountRowViewModel?.id == nil && viewModel != nil {
            let account = FMAccount(name: name, comments: comments)
            viewModel?.addNew(account: account, resultBlock: { error in
                if let error = error {
                    alertInfoMessage = error.localizedDescription
                    shouldShowAlert = true
                } else {
                    shouldPresentAddAccountView.toggle()
                }
            })
        } else {
            if let account = accountRowViewModel?.account {
                var updatedAccount = account
                updatedAccount.name = name
                updatedAccount.comments = comments
                accountRowViewModel?.update(account: updatedAccount, resultBlock: { error in
                    if let error = error {
                        alertInfoMessage = error.localizedDescription
                        shouldShowAlert = true
                    } else {
                        shouldPresentAddAccountView.toggle()
                    }
                })
            }
        }
    }
    
}

struct FMAddAccount_Previews: PreviewProvider {
    static var previews: some View {
        FMAddAccountView(shouldPresentAddAccountView: .constant(false), viewModel: FMAccountListViewModel())
    }
}
