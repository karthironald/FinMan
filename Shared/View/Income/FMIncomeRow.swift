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
            Image(systemName: "\(incomeRowViewModel.imageName()).square.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.trailing, 5)
                .foregroundColor(.secondary)
                .opacity(0.5)
            VStack(alignment: .leading, spacing: 5) {
                Text("\(incomeRowViewModel.income.value, specifier: "%0.2f")")
                    .font(.body)
                    .bold()
                Text("\(incomeRowViewModel.income.createdAt?.dateValue() ?? Date(), style: .time)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
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
