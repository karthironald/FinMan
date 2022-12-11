//
//  FMSummaryView.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 08/12/22.
//

import Foundation
import SwiftUI
import Charts

struct FMSummaryView: View {
    
    @StateObject var transactionRepository = FMDTransactionRepository.shared
    @State private var selectedTimePeriod = FMTimePeriod.thisMonth
    @State private var shouldExplainIncome = false
    @State private var shouldExplainExpense = false
    
    var body: some View {
        ScrollView {
            VStack {
                LabeledContent {
                    Text(transactionRepository.summary?.totalIncome?.localCurrencyString() ?? "-")
                        .foregroundColor(Color.green)
                } label: {
                    Text("Total Income")
                }
                .font(.title3)
                .bold()
                
                Chart {
                    ForEach(transactionRepository.summary?.incomes ?? [], id: \.source) { income in
                        BarMark(
                            x: .value("Value", income.value ?? 0.0)
                        )
                        .foregroundStyle(by: .value("Source", income.source ?? "-"))
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 100)
                .onTapGesture {
                    withAnimation {
                        shouldExplainIncome.toggle()
                    }
                }
                
                if shouldExplainIncome {
                    ForEach(transactionRepository.summary?.incomes ?? [], id: \.source) { income in
                        LabeledContent {
                            Text(income.value?.localCurrencyString() ?? "-")
                        } label: {
                            Text(income.source ?? "-")
                        }
                    }
                }
                
                LabeledContent {
                    Text(transactionRepository.summary?.totalExpense?.localCurrencyString() ?? "-")
                        .foregroundColor(Color.red)
                } label: {
                    Text("Total Expense")
                }
                .font(.title3)
                .bold()
                .padding(.top)
                
                Chart {
                    ForEach(transactionRepository.summary?.expenses ?? [], id: \.category) { expense in
                        BarMark(
                            x: .value("Value", expense.value ?? 0.0)
                        )
                        .foregroundStyle(by: .value("Category", expense.category ?? "-"))
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 100)
                .onTapGesture {
                    withAnimation {
                        shouldExplainExpense.toggle()
                    }
                }
                
                if shouldExplainExpense {
                    ForEach(transactionRepository.summary?.expenses ?? [], id: \.category) { expense in
                        LabeledContent {
                            Text(expense.value?.localCurrencyString() ?? "-")
                        } label: {
                            Text(expense.category ?? "-")
                        }
                    }
                }
                
                LabeledContent {
                    Text(balance().localCurrencyString() ?? "-")
                        .foregroundColor(Color.blue)
                } label: {
                    Text("Balance")
                }
                .font(.title3)
                .bold()
                .padding(.top)
                
                VStack {
                    Text("Budget vs Actual")
                    Chart {
                        ForEach(budgetActualData(), id: \.name) { series in
                            ForEach(series.expenseData) { element in
                                BarMark(
                                    x: .value("Value", element.value ?? 0.0),
                                    y: .value("Category", element.name ?? "-")
                                )
                            }
                            .foregroundStyle(by: .value("Category", series.name))
                            .position(by: .value("Category", series.name))
                        }
                    }
                }
                .chartPlotStyle { plotContent in
                    plotContent.frame(height: 44 * CGFloat(transactionRepository.summary?.expenses?.count ?? 0))
                }
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width - 30)
            .navigationBarItems(trailing: filterMenu())
            .onAppear {
                fetchSummary()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(15)
    }
    
    func budgetActualData() -> [(name: String, expenseData: [FMSummary.ChartComparison])] {
        let budgetData = transactionRepository.summary?.expenses?.map { FMSummary.ChartComparison(name: $0.category, value: $0.monthlyBudget) } ?? []
        let actualData = transactionRepository.summary?.expenses?.map{ FMSummary.ChartComparison(name: $0.category, value: $0.value) } ?? []
                                                                                
        return [("budget", budgetData), ("actual", actualData)]
    }
    
    func balance() -> Double {
        (transactionRepository.summary?.totalIncome ?? 0.0) - (transactionRepository.summary?.totalExpense ?? 0.0)
    }
    
    func fetchSummary() {
        let dates = FMHelper.startDate(type: selectedTimePeriod)
        if let sDate = dates.startDate, let eDate = dates.endDate {
            transactionRepository.summary(startDate: sDate, endDate: eDate)
        }
    }
    
    func filterMenu() -> some View {
        Picker("Time Period", selection: $selectedTimePeriod) {
            ForEach(FMTimePeriod.allCases, id: \.self) { tp in
                Text(tp.title())
            }
        }.onChange(of: selectedTimePeriod) { newValue in
            fetchSummary()
        }
    }
    
}

struct FMSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let summary = FMSummary(totalExpense: 23000, totalIncome: 57000, incomes: [FMSummary.Income(source: "Salary", value: 57000)], expenses: [FMSummary.Expense(category: "Fuel", value: 100, monthlyBudget: 1000), FMSummary.Expense(category: "Lunch", value: 500, monthlyBudget: 1000), FMSummary.Expense(category: "Service", value: 10000, monthlyBudget: 5000), FMSummary.Expense(category: "Others", value: 14400, monthlyBudget: 20000)])
        FMDTransactionRepository.shared.summary = summary
        return FMSummaryView(transactionRepository: FMDTransactionRepository.shared)
    }
}


extension FMSummary {
    
    struct ChartComparison: Identifiable {
        let name: String?
        let value: Double?
        
        var id: String { name ?? "-" }
    }
    
}
