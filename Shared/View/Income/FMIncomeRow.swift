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
        VStack(alignment: .leading) {
            Text("\(income.value, specifier: "%0.2f")")
                .font(.body)
                .bold()
            Text("\(income.frequency.rawValue)")
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct FMIncomeRow_Previews: PreviewProvider {
    static var previews: some View {
        FMIncomeRow(income: FMIncome.sampleData.first ?? FMIncome(id: UUID(), value: 100, frequency: .halfEarly))
    }
}
