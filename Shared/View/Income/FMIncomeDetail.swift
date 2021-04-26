//
//  FMIncomeDetail.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 18/04/21.
//

import SwiftUI

struct FMIncomeDetail: View {
    
    var income: FMIncome
    @ObservedObject var viewModel: FMIncomeListViewModel
    @State var shouldPresentEditScreen = false
    
    var body: some View {
        List {
            HStack {
                Text("Value")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(income.value, specifier: "%0.02f")")
            }
            HStack {
                Text("Frequency")
                    .foregroundColor(.secondary)
                Spacer()
                Text(FMIncome.Frequency(rawValue: income.frequency)?.title ?? "")
            }
            HStack {
                Text("Additional Comments")
                    .foregroundColor(.secondary)
                Spacer()
                Text(income.comments ?? "-")
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
    }
}

struct FMIncomeDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FMIncomeDetail(income: FMIncome.sampleData.first!, viewModel: FMIncomeListViewModel())
        }
    }
}
