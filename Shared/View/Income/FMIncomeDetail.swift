//
//  FMIncomeDetail.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 18/04/21.
//

import SwiftUI

struct FMIncomeDetail: View {
    
    @ObservedObject var incomeRowViewModel: FMIncomeRowViewModel
    @State var shouldPresentEditScreen = false
    
    var body: some View {
        List {
            HStack {
                Text("Value")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(incomeRowViewModel.income.value, specifier: "%0.02f")")
            }
            HStack {
                Text("Frequency")
                    .foregroundColor(.secondary)
                Spacer()
                Text(FMIncome.Frequency(rawValue: incomeRowViewModel.income.frequency)?.title ?? "")
            }
            HStack {
                Text("Additional Comments")
                    .foregroundColor(.secondary)
                Spacer()
                Text(incomeRowViewModel.income.comments ?? "-")
            }
        }
        .navigationBarTitle("Income Details", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            shouldPresentEditScreen.toggle()
        }, label: {
            Image(systemName: "pencil.circle")
                .resizable()
                .font(.title)
        }))
        .sheet(isPresented: $shouldPresentEditScreen) {
            FMAddIncomeview(value: String(incomeRowViewModel.income.value), frequencyIndex: incomeRowViewModel.income.frequency, comments: incomeRowViewModel.income.comments ?? " ", incomeRowViewModel: incomeRowViewModel, shouldPresentAddIncomeView: $shouldPresentEditScreen)
        }
    }
}

struct FMIncomeDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FMIncomeDetail(incomeRowViewModel: FMIncomeRowViewModel(income: FMIncome.sampleData.first!))
        }
    }
}
