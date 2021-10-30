//
//  FMTransactionListView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 09/04/21.
//

import Foundation
import SwiftUI
import KSCharts

struct FMTransactionListView: View {
    
    @StateObject var viewModel = FMTransactionListViewModel()
    
    @State var shouldPresentAddTransactionView: Bool = false
    @State var shouldPresentAddAccountView: Bool = false
    @State var shouldSourceShowChart: Bool = false
    @State private var alertInfoMessage = ""
    @State private var shouldShowAlert = false
    @ObservedObject var accountViewModel: FMAccountRowViewModel
    @State private var selectedTimePeriod = FMTimePeriod.thisMonth
    @State private var selectedIncomeSourceIndex = kCommonIndex
    @State private var transactionTypeIndex = 1 // Index of 'Expense' transaction type
    @State private var chartType: ChartType = .pie
    
    // MARK: - View Body
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    Text("\(selectedTimePeriod.title()) (\(FMHelper.selectedTimePeriodDisplayString(timePeriod: selectedTimePeriod) ?? "-"))")
                        .foregroundColor(.secondary)
                    HStack {
                        Spacer()
                        Text("\(viewModel.totalIncome, specifier: "%0.2f")")
                            .foregroundColor(.green)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Color.green.opacity(0.1))
                            .clipShape(Capsule())
                        Spacer()
                        Image(systemName: "minus")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(viewModel.totalExpense, specifier: "%0.2f")")
                            .foregroundColor(.red)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Capsule())
                        Group {
                            Spacer()
                            Image(systemName: "equal")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        Text("\(viewModel.totalIncome - viewModel.totalExpense, specifier: "%0.2f")")
                            .foregroundColor(.blue)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                        Spacer()
                    }
                }
                .font(.caption)
                .padding(10)
                .background(AppSettings.appSecondaryColour.opacity(0.2))
                .zIndex(2) // Workaround to fix list selection issue
                
                List {
                    ForEach(Array(viewModel.groupedTransactionRowViewModel.keys.sorted(by: >)), id: \.self) { (key) in
                        Section(header: Text("\(key) (\(viewModel.groupedTransactionRowViewModel[key]!.count))")) {
                            ForEach(viewModel.groupedTransactionRowViewModel[key]!, id: \.id) { transactionRowViewModel in
                                NavigationLink(
                                    destination: FMTransactionDetailView(transactionRowViewModel: transactionRowViewModel),
                                    label: {
                                        FMTransactionRowView(transactionRowViewModel: transactionRowViewModel)
                                    }
                                )
                            }
                            .onDelete { (indexSet) in
                                if let index = indexSet.first {
                                    viewModel.transactionRowViewModel[index].delete(resultBlock: { error in
                                        if let error = error {
                                            alertInfoMessage = error.localizedDescription
                                            shouldShowAlert = true
                                        }
                                    })
                                }
                            }
                        }
                    }
                    Section {
                        Button(viewModel.isFetching ? "Loading..." : "Load More...") {
                            viewModel.fetchNextBadge()
                        }
                        .disabled(!viewModel.shouldEnableLoadMore())
                    }
                }
                .alert(isPresented: $shouldShowAlert, content: {
                    Alert(title: Text(alertInfoMessage), message: nil, dismissButton: Alert.Button.default(Text(kOkay), action: {
                        // Do nothing
                    }))
                })
                .padding(0)
                .frame(minWidth: 250)
                .listStyle(InsetGroupedListStyle())
            }
            addTransactionView()
        }
        .navigationBarItems(trailing: trainingViews())
        .onAppear(perform: {
            FMAccountRepository.shared.selectedAccount = accountViewModel.account
            fetchTransaction()
        })
        .navigationBarTitle("\(accountViewModel.account.name.capitalized)", displayMode: .inline)
        .popup(isPresented: $shouldPresentAddTransactionView, overlayView: {
            BottomPopupView(title: "Add Transaction", shouldDismiss: $shouldPresentAddTransactionView) {
                FMAddTransactionView(viewModel: viewModel, shouldPresentAddTransactionView: $shouldPresentAddTransactionView)
                    .accentColor(AppSettings.appPrimaryColour)
            }
        })
        .sheet(isPresented: $shouldSourceShowChart, content: {
            let transactionType = (transactionTypeIndex > (FMTransaction.TransactionType.allCases.count - 1)) ? nil : FMTransaction.TransactionType.allCases[transactionTypeIndex]
            VStack {
                Picker("Chart Type", selection: $chartType.animation()) {
                    ForEach(ChartType.allCases, id: \.self) { transType in
                        Image(systemName: transType.iconName)
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                }
                .accentColor(AppSettings.appPrimaryColour)
                .pickerStyle(SegmentedPickerStyle())
                .padding([.horizontal, .top])

                if chartType == .pie {
                    KSPieChart(dataPointsWithTitle: viewModel.chartPoints(transactionType: transactionType))
                } else {
                    KSHorizontalBarChartView(dataPointsWithTitle: viewModel.chartPoints(transactionType: transactionType))
                }
            }
        })
    }
    
    
    // MARK: - Custom methods
    
    func fetchTransaction() {
        let source = (selectedIncomeSourceIndex > (FMTransaction.IncomeSource.allCases.count - 1)) ? nil : FMTransaction.IncomeSource.allCases[selectedIncomeSourceIndex]
        let transactionType = (transactionTypeIndex > (FMTransaction.TransactionType.allCases.count - 1)) ? nil : FMTransaction.TransactionType.allCases[transactionTypeIndex]
        viewModel.fetchTransaction(for: selectedTimePeriod, incomeSource: source, transactionType: transactionType)
    }
    
    func addTransactionView() -> some View {
        Button(action: {
            shouldPresentAddTransactionView.toggle()
        }, label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
        })
        .foregroundColor(AppSettings.appPrimaryColour)
        .frame(width: 44, height: 44)
        .background(Color.white)
        .clipShape(Circle())
        .padding()
    }
    
    func chartButtonView() -> some View {
        Button(action: {
            shouldSourceShowChart.toggle()
        }, label: {
            Image(systemName: "chart.bar.doc.horizontal")
                .resizable()
                .font(.title2)
        })
        .foregroundColor((transactionTypeIndex > (FMTransaction.TransactionType.allCases.count - 1)) ? .secondary.opacity(0.5) : AppSettings.appPrimaryColour)
        .disabled((transactionTypeIndex > (FMTransaction.TransactionType.allCases.count - 1))) // Disable buttonw when 'Both' transaction type is selected
    }
    
    func trainingViews() -> some View {
        HStack(spacing: 20) {
            chartButtonView()
            Menu {
                transactionTypeFilter()
                filterMenu()
                filterSourceView()
            } label: {
                Image(systemName: "magnifyingglass.circle")
                    .resizable()
                    .font(.title2)
            }
        }
        .frame(height: 25, alignment: .center)
    }
    
    func transactionTypeFilter() -> some View {
        Menu {
            ForEach(0...FMTransaction.TransactionType.allCases.count, id: \.self) { index in
                Button("\(index == FMTransaction.TransactionType.allCases.count ? "Both" : FMTransaction.TransactionType.allCases[index].rawValue.capitalized)") {
                    transactionTypeIndex = index
                    fetchTransaction()
                }
            }
        } label: {
            Text("Transaction Type:  \((transactionTypeIndex > (FMTransaction.TransactionType.allCases.count - 1)) ? "Both" : FMTransaction.TransactionType.allCases[transactionTypeIndex].rawValue.capitalized)")
                .frame(width: 100, height: 30, alignment: .trailing)
        }
    }
    
    func filterMenu() -> some View {
        Menu {
            ForEach(0..<FMTimePeriod.allCases.count, id: \.self) { index in
                Button("\(FMTimePeriod.allCases[index].title())") {
                    selectedTimePeriod = FMTimePeriod.allCases[index]
                    fetchTransaction()
                }
            }
        } label: {
            Text("Period:  \(selectedTimePeriod.title())")
                .frame(width: 100, height: 30, alignment: .trailing)
        }
    }
    
    func filterSourceView() -> some View {
        Menu {
            ForEach(0...FMTransaction.IncomeSource.allCases.count, id: \.self) { index in
                Button("\(index == FMTransaction.IncomeSource.allCases.count ? "Any" : FMTransaction.IncomeSource.allCases[index].title)") {
                    selectedIncomeSourceIndex = index
                    fetchTransaction()
                }
            }
        } label: {
            Text("Income Source:  \((selectedIncomeSourceIndex > (FMTransaction.IncomeSource.allCases.count - 1)) ? "Any" : FMTransaction.IncomeSource.allCases[selectedIncomeSourceIndex].title)")
                .frame(width: 100, height: 30, alignment: .trailing)
        }
    }
    
}

struct FMTransactionListView_Previews: PreviewProvider {
    
    static var previews: some View {
        let viewModel = FMTransactionListViewModel()
        let rowViewModel = FMTransactionRowViewModel(transaction: FMTransaction.sampleData.first!)
        viewModel.transactionRowViewModel = [rowViewModel]
        return NavigationView {
            FMTransactionListView(viewModel: viewModel, shouldPresentAddTransactionView: false, accountViewModel: FMAccountRowViewModel(account: FMAccount.sampleData.first!))
        }
    }
    
}


enum ChartType: CaseIterable {
    case pie, bar
    
    var iconName: String {
        switch self {
        case .bar: return "chart.bar.doc.horizontal"
        case .pie: return "chart.pie"
        }
    }
}
