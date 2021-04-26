//
//  FMIncomeRow.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 09/04/21.
//

import SwiftUI

struct FMIncomeRow: View {
    
    let income: FMIncome
    
    var body: some View {
        HStack(alignment: .center) {
            Text("\(income.value, specifier: "%0.2f")")
                .font(.body)
                .bold()
            Spacer()
            Text("\(FMIncome.Frequency(rawValue: income.frequency)?.title ?? "")")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

struct FMIncomeRow_Previews: PreviewProvider {
    static var previews: some View {
        FMIncomeRow(income: FMIncome.sampleData.first ?? FMIncome(id: UUID().uuidString, value: 100, frequency: 0))
    }
}
