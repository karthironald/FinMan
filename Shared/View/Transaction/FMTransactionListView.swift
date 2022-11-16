//
//  FMTransactionListView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 09/04/21.
//

import Foundation
import SwiftUI

struct FMTransactionListView: View {
    
    @EnvironmentObject private var currentUser: FMCurrentUser
    
    @StateObject var viewModel = FMTransactionListViewModel()
    
    @State var shouldPresentAddTransactionView: Bool = false
    @State var shouldPresentAddAccountView: Bool = false
    @State var shouldSourceShowChart: Bool = false
    @State private var alertInfoMessage = ""
    @State private var shouldShowAlert = false
    @State private var selectedTimePeriod = FMTimePeriod.today
    @State private var selectedIncomeSourceIndex = kCommonIndex
    @State private var transactionTypeIndex = 1 // Index of 'Expense' transaction type
    
    
    // MARK: - View Body
    
    var body: some View {
        NavigationView {
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
            .frame(minWidth: 250)
            .listStyle(InsetGroupedListStyle())
            .navigationBarItems(leading: trainingViews(), trailing: addTransactionView())
            .onAppear(perform: {
                fetchTransaction()
            })
            .navigationBarTitle("Transactions")
        }
        .popup(isPresented: $shouldPresentAddTransactionView, overlayView: {
            BottomPopupView(title: "Add Transaction", shouldDismiss: $shouldPresentAddTransactionView) {
                FMAddTransactionView(viewModel: viewModel, shouldPresentAddTransactionView: $shouldPresentAddTransactionView)
                    .accentColor(AppSettings.appPrimaryColour)
            }
        })
//        .popup(isPresented: $shouldSourceShowChart, overlayView: {
//            BottomPopupView(title: "Chart", shouldDismiss: $shouldSourceShowChart) {
//                let transactionType = (transactionTypeIndex > (FMTransaction.TransactionType.allCases.count - 1)) ? nil : FMTransaction.TransactionType.allCases[transactionTypeIndex]
//                FMChartView(points: viewModel.chartPoints(transactionType: transactionType))
//                    .accentColor(AppSettings.appPrimaryColour)
//            }
//        })
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
//        .foregroundColor(AppSettings.appPrimaryColour)
//        .frame(width: 44, height: 44)
//        .background(Color.white)
//        .clipShape(Circle())
//        .padding()
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
        HStack{
            Button {
                currentUser.isUserLoggedIn = false
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .resizable()
            }

            filterMenu()
        }
        
//        HStack(spacing: 20) {
//            chartButtonView()
//            Menu {
////                transactionTypeFilter()
//                filterMenu()
////                filterSourceView()
//            } label: {
//                Image(systemName: "magnifyingglass.circle")
//                    .resizable()
//                    .font(.title2)
//            }
//        }
//        .frame(height: 25, alignment: .center)
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
        Picker("Time Period", selection: $selectedTimePeriod) {
            ForEach(FMTimePeriod.allCases, id: \.self) { tp in
                Text(tp.title())
            }
        }.onChange(of: selectedTimePeriod) { newValue in
            fetchTransaction()
        }
//        Menu {
//
//        } label: {
//            Image(systemName: "magnifyingglass.circle")
//                .resizable()
//                .font(.title2)
//        }
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
        let rowViewModel = FMTransactionRowViewModel(transaction: FMDTransaction(id: 1, incomeSource: FMDIncomeSource(id: 1, createdAt: Date(), updatedAt: Date(), name: "IC", frequency: "onetime"), expenseCategory: FMDExpenseCategory(id: 1, createdAt: Date(), updatedAt: Date(), name: "EC 1", monthlyBudget: 10, yearlyBudget: 120), event: nil, account: FMAccount.sampleData.first!, createdAt: Date(), updatedAt: Date(), name: "New Transaction", value: 100, transactionAt: Date(), transactionType: "income", comments: "Sample"))
        viewModel.transactionRowViewModel = [rowViewModel]
        return NavigationView {
            FMTransactionListView(viewModel: viewModel, shouldPresentAddTransactionView: false)
        }
    }
    
}


struct FMChartView: View {
    
    var total: Double {
        points.reduce(0) { result, point in
            result + point.1
        }
    }
    var points: [(String, Double)]
    
    
    // MARK: - View Body
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<points.count, id: \.self) { index in
                GeometryReader { proxy in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(points[index].0.capitalized)
                            .font(.caption)
                        HStack {
                            ZStack(alignment: .leading) {
                                Image("dottedLine")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.secondary.opacity(0.2))
                                    .frame(height: 1, alignment: .center)
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(AppSettings.appPrimaryColour)
                                    .scaleEffect(CGSize(width: normalizedValue(index: index), height: 1.0), anchor: .leading)
                            }
                            Spacer()
                            Text("\(FMHelper.percentage(of: points[index].1, in: total), specifier: "%0.2f") %")
                                .font(.caption2)
                                .bold()
                        }
                        .frame(width: proxy.size.width, height: 5)
                    }
                }
            }
        }
        .onAppear {
            
        }
        .frame(height: CGFloat(40 * points.count), alignment: .center)
        .padding()
    }
    
    
    // MARK: - Custom methods
    
    func normalizedValue(index: Int) -> Double {
        var allValues: [Double]    {
            var values = [Double]()
            for point in points {
                values.append(point.1)
            }
            return values
        }
        guard let max = allValues.max() else {
            return 1
        }
        if max != 0 {
            return Double(points[index].1)/Double(max)
        } else {
            return 1
        }
    }
    
}
