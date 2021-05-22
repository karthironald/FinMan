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
    
    @ObservedObject var viewModel: FMAccountListViewModel
    
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
            .navigationBarTitle(Text("Add Account"), displayMode: .inline)
            .navigationBarItems(trailing: saveButtonView())
        }
    }
    
    func saveButtonView() -> some View {
        Button("Save") {
            saveButtonTapped()
            shouldPresentAddAccountView.toggle()
        }
        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    func saveButtonTapped() {
        let account = FMAccount(name: name, comments: comments)
        viewModel.addNew(account: account)
//        if accountRowViewModel?.id == nil && viewModel != nil {
//            let account = FMAccount(name: name, comments: comments)
//            viewModel.addNew(account: account)
//        } else {
//            if let account = accountRowViewModel?.account {
//                var updatedAccount = account
//                updatedAccount.name = name
//                updatedAccount.comments = comments
//                accountRowViewModel?.update(account: updatedAccount)
//            }
//        }
    }
    
}

struct FMAddAccount_Previews: PreviewProvider {
    static var previews: some View {
        FMAddAccountView(shouldPresentAddAccountView: .constant(false), viewModel: FMAccountListViewModel())
    }
}
