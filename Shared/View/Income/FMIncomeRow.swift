//
//  FMIncomeRow.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 09/04/21.
//

import SwiftUI

struct FMIncomeRow: View {
    
    @ObservedObject var incomeRowViewModel: FMIncomeRowViewModel
    
    var body: some View {
        HStack(alignment: .center) {
            Text("\(incomeRowViewModel.income.value, specifier: "%0.2f")")
                .font(.body)
                .bold()
            Spacer()
            Text("\(FMIncome.Frequency(rawValue: incomeRowViewModel.income.frequency)?.title ?? "")")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

struct FMIncomeRow_Previews: PreviewProvider {
    static var previews: some View {
        FMIncomeRow(incomeRowViewModel: FMIncomeRowViewModel(income: FMIncome.sampleData.first!))
    }
}
