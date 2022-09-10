//
//  FMAddTransactionView.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 10/04/21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FMAddTransactionView: View {
    
    @EnvironmentObject private var hud: FMLoadingInfoState
    @Namespace private var animation
    
    @State var name: String = ""
    @State var value: String = ""
    @State var account = FMAccount.default
    @State var event = FMEvent.default
    
    @State var comments: String = ""
    @State var source: FMDIncomeSource = FMDIncomeSource.default
    @State var transactionType: FMTransaction.TransactionType = .expense
    
    @State var expenseCategory = FMDExpenseCategory.default
    @State var transactionDate: Date = Date()
    
    @State var shouldShowIncomeSource = false
    @State var shouldShowExpenseCategory = false
    
    @State private var alertInfoMessage = ""
    @State private var shouldShowAlert = false
    
    @State private var keyboardWillShow = NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification, object: nil)
    @State private var keyboardWillHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification, object: nil)
    @State private var bottomPadding: CGFloat = 0
    
    @StateObject var isRepo = FMIncomeSourceRepository()
    @StateObject var ecRepo = FMExpenseCategoryRepository()
    @StateObject var eventRepo = FMEventRepository()
    @StateObject var accountRepo = FMAccountRepository()
    
    var viewModel: FMTransactionListViewModel? = nil
    var transactionRowViewModel: FMTransactionRowViewModel? = nil
    @Binding var shouldPresentAddTransactionView: Bool
    
    
    // MARK: - View Body
    
    var body: some View {
        ZStack {
            VStack(spacing: AppSettings.vStackSpacing) {
                HStack {
                    Text("Name").foregroundColor(.secondary)
                    Spacer()
                    FMTextField(title: "Enter name", keyboardType: .default, height: 40, value: $name, infoMessage: .constant(""))
                        .frame(width: 200, alignment: .center)
                }
                HStack {
                    Text("Amount").foregroundColor(.secondary)
                    Spacer()
                    FMTextField(title: "Enter amount", keyboardType: .decimalPad, height: 40, value: $value, infoMessage: .constant(""))
                        .frame(width: 200, alignment: .center)
                }
                
                HStack {
                    Text("Type").foregroundColor(.secondary)
                    Spacer()
                    Picker("Type", selection: $transactionType.animation()) {
                        ForEach(FMTransaction.TransactionType.allCases, id: \.self) { transType in
                            Text("\(transType.rawValue.capitalized)")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200, alignment: .center)
                }
                if transactionType == .income {
                    HStack {
                        Text("Source").foregroundColor(.secondary)
                        Spacer()
                        if isRepo.isFetching {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Picker("Source", selection: $source) {
                                ForEach(isRepo.sources, id: \.self) { ic in
                                    Text("\((ic.name ?? "").capitalized)")
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .id(isRepo.sources) // Added to force rerender picker view as soon as income sources fetched from server
                        }
                    }
                } else {
                    HStack {
                        Text("Category").foregroundColor(.secondary)
                        Spacer()
                        if ecRepo.isFetching {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Picker("Expense Category", selection: $expenseCategory) {
                                ForEach(ecRepo.category, id: \.self) { ec in
                                    Text("\((ec.name ?? "").capitalized)")
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .id(ecRepo.category) // Added to force rerender picker view as soon as expense category fetched from server
                        }
                    }
                }
                HStack {
                    Text("Date").foregroundColor(.secondary)
                    Spacer()
                    DatePicker("", selection: $transactionDate)
                }
                HStack {
                    Text("Account").foregroundColor(.secondary)
                    Spacer()
                    if accountRepo.isFetching {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Picker("Account", selection: $account) {
                            ForEach(accountRepo.accounts, id: \.self) { acc in
                                Text("\((acc.name ?? "").capitalized)")
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .id(accountRepo.accounts) // Added to force rerender picker view as soon as accounts fetched from server
                    }
                }
                HStack {
                    Text("Event").foregroundColor(.secondary)
                    Spacer()
                    if eventRepo.isFetching {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Picker("Event", selection: $event) {
                            ForEach(eventRepo.events, id: \.self) { eve in
                                Text("\((eve.name ?? "").capitalized)")
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .id(eventRepo.events) // Added to force rerender picker view as soon as events fetched from server
                    }
                }
                HStack {
                    Text("Comments").foregroundColor(.secondary)
                    Spacer()
                    FMTextField(title: "Enter comments", keyboardType: .default, height: 40, value: $comments, infoMessage: .constant(""))
                        .frame(width: 200, alignment: .center)
                }
                FMButton(title: "Save", type: .primary, shouldShowLoading: hud.shouldShowLoading) {
                    saveButtonTapped()
                }
                .disabled(!shouldEnableSaveButton())
                .padding(.top)
            }
        }
        .onAppear {
            if isRepo.sources.isEmpty {
                isRepo.getIncomeSources()
            }
            if ecRepo.category.isEmpty {
                ecRepo.getExpenseCategory()
            }
            if accountRepo.accounts.isEmpty {
                accountRepo.getAccounts()
            }
            if eventRepo.events.isEmpty {
                eventRepo.getEvents()
            }
        }
        .onReceive(keyboardWillShow) { _ in
            bottomPadding = 80
        }
        .onReceive(keyboardWillHide) { _ in
            bottomPadding = 20
        }
        .onChange(of: eventRepo.events, perform: { newValue in
            if let event = eventRepo.events.first {
                self.event = event
            }
        })
        .onChange(of: accountRepo.accounts, perform: { newValue in
            if let acc = accountRepo.accounts.first {
                account = acc
            }
        })
        .onChange(of: isRepo.sources, perform: { newValue in
            if let incomeSource = isRepo.sources.first {
                source = incomeSource
            }
        })
        .onChange(of: ecRepo.category, perform: { newValue in
            if let expenseCategory = ecRepo.category.first {
                self.expenseCategory = expenseCategory
            }
        })
        .accentColor(AppSettings.appPrimaryColour)
        .padding(.horizontal) // We are not setting `top` padding as we have padding in the BottomPopup title's bottom.
        .padding(.bottom)
        .padding(.bottom, bottomPadding) // To make the save button visisble when keyboard is presented
    }
    
    
    // MARK: - Custom methods
    
    private func saveButtonTapped() {
        if transactionRowViewModel?.id == nil && viewModel != nil {
            let transaction = FMAddTransactionRequest(name: name, value: Double(value) ?? 0.0, transactionType: transactionType.rawValue, accountID: account.id, expenseCategoryID: expenseCategory.id, eventID: event.id, incomeSourceID: source.id, transactionAt: transactionDate.toString(format: .isoDateTimeMilliSec, timeZone: .local, locale: .current), comments: comments)
            hud.startLoading()
            viewModel?.addNew(transaction: transaction, resultBlock: { error in
                hud.stopLoading()
                if let error = error {
                    alertInfoMessage = error.localizedDescription
                    shouldShowAlert.toggle()
                } else {
                    shouldPresentAddTransactionView.toggle()
                }
            })
//            var transaction = FMTransaction(value: Double(value) ?? 0.0)
//            if transactionType == .income {
//                transaction.frequency = frequency.rawValue
//                transaction.source = source.rawValue
//            } else {
//                transaction.expenseCategory = expenseCategory.rawValue
//            }
//            transaction.transactionType = transactionType.rawValue
//            transaction.comments = comments
//            transaction.transactionDate = Timestamp(date: transactionDate)
//            
//            hud.startLoading()

        } else {
//            if let transaction = transactionRowViewModel?.transaction {
//                var updatedTransaction = transaction
//                updatedTransaction.value = Double(value) ?? 0.0
//                if transactionType == .income {
//                    updatedTransaction.frequency = frequency.rawValue
//                    updatedTransaction.source = source.rawValue
//                } else {
//                    updatedTransaction.expenseCategory = expenseCategory.rawValue
//                }
//                updatedTransaction.transactionType = transactionType.rawValue
//                updatedTransaction.transactionDate = Timestamp(date: transactionDate)
//                updatedTransaction.comments = comments
//
//                hud.startLoading()
//                transactionRowViewModel?.update(transaction: updatedTransaction, resultBlock: { error in
//                    hud.stopLoading()
//                    if let error = error {
//                        alertInfoMessage = error.localizedDescription
//                        shouldShowAlert.toggle()
//                    } else {
//                        shouldPresentAddTransactionView.toggle()
//                    }
//                })
//            }
        }
    }
    
    func shouldEnableSaveButton() -> Bool {
        return true
//        if transactionRowViewModel?.id == nil && viewModel != nil {
//            return Double(value) ?? 0.0 > 0.0
//        } else {
//            if let originalSource = transactionRowViewModel?.transaction.source, !originalSource.isEmpty, (source.rawValue.lowercased() != originalSource.lowercased()) {
//                return true
//            }
//            if let originalFreq = transactionRowViewModel?.transaction.frequency, !originalFreq.isEmpty, (frequency.rawValue.lowercased() != originalFreq.lowercased()) {
//                return true
//            }
//            if let originalExpenseCategory = transactionRowViewModel?.transaction.expenseCategory, !originalExpenseCategory.isEmpty, (expenseCategory.rawValue.lowercased() != originalExpenseCategory.lowercased()) {
//                return true
//            }
//            let value = Double(value) ?? 0.0
//            return ((value > 0.0) && value != transactionRowViewModel?.transaction.value) || (transactionType.rawValue.lowercased() != transactionRowViewModel?.transaction.transactionType.lowercased()) || (transactionDate != transactionRowViewModel?.transaction.transactionDate?.dateValue()) || (comments.lowercased() != transactionRowViewModel?.transaction.comments?.lowercased())
//        }
    }
    
}

struct FMAddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        FMAddTransactionView(viewModel: FMTransactionListViewModel(), shouldPresentAddTransactionView: .constant(false))
    }
}

struct TagStyledButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 30)
            .padding(.horizontal)
            .background(AppSettings.appPrimaryColour.opacity(0.2))
            .foregroundColor(AppSettings.appPrimaryColour)
            .clipShape(Capsule())
    }
}
