//
//  FMAddAccount.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/05/21.
//

import SwiftUI

struct FMAddAccountView: View {
    
    @EnvironmentObject private var hud: FMLoadingInfoState
    
    @State var name: String = ""
    @State var comments: String = ""
    @Binding var shouldPresentAddAccountView: Bool
    @State var nameInfoMessage = ""
    
    var viewModel: FMAccountListViewModel? = nil
    var accountRowViewModel: FMAccountRowViewModel? = nil
    
    
    // MARK: - View Body
    
    var body: some View {
        VStack(spacing: AppSettings.vStackSpacing) {
            FMTextField(title: "Enter account name", value: $name, infoMessage: $nameInfoMessage)
            ZStack(alignment: .topLeading) {
                if comments.isEmpty {
                    Text("Enter additional comments (if any)")
                        .foregroundColor(.secondary)
                        .opacity(0.5)
                        .padding([.top, .leading], 20)
                }
                TextEditor(text: $comments)
                    .modifier(FMTextEditorThemeModifier(keyboardType: .default))
            }
            .padding(.bottom)
            saveButtonView()
        }
        .onAppear(perform: {
            UITextView.appearance().backgroundColor = .clear
        })
        .padding([.horizontal, .bottom]) // We are not setting `top` padding as we have padding in the BottomPopup title's bottom.
    }
    
    
    // MARK: - Custom methods
    
    func saveButtonView() -> some View {
        FMButton(title: "Save", type: .primary, shouldShowLoading: hud.shouldShowLoading) {
            saveButtonTapped()
        }
        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    func saveButtonTapped() {
        if accountRowViewModel?.id == nil && viewModel != nil {
            hud.startLoading()
            viewModel?.addNew(name: name, comments: comments, resultBlock: { error in
                hud.stopLoading()
                if let error = error {
                    hud.show(title: error.localizedDescription, type: .error)
                } else {
                    shouldPresentAddAccountView.toggle()
                }
            })
        } else {
            if let account = accountRowViewModel?.account {
                var updatedAccount = account
                updatedAccount.name = name
                updatedAccount.accountDescription = comments
                hud.startLoading()
                accountRowViewModel?.update(account: updatedAccount, resultBlock: { error in
                    hud.stopLoading()
                    if let error = error {
                        hud.show(title: error.localizedDescription, type: .error)
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
