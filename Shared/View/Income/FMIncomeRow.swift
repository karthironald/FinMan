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
            Image(systemName: "\(FMIncome.Source(rawValue: incomeRowViewModel.income.source)?.imageName ?? "")")
                .resizable()
                .frame(width: 25, height: 25)
                .padding(.trailing, 5)
            VStack(alignment: .leading) {
                Text("\(incomeRowViewModel.income.value, specifier: "%0.2f")")
                    .font(.body)
                    .bold()
                HStack {
                    Text("\(incomeRowViewModel.income.createdAt?.dateValue() ?? Date(), style: .date)")
                    Text("\(incomeRowViewModel.income.createdAt?.dateValue() ?? Date(), style: .time)")
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(FMIncome.Frequency(rawValue: incomeRowViewModel.income.frequency)?.title ?? "")")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding([.top, .bottom], 5)
    }
}

struct FMIncomeRow_Previews: PreviewProvider {
    static var previews: some View {
        FMIncomeRow(incomeRowViewModel: FMIncomeRowViewModel(income: FMIncome.sampleData.first!))
    }
}
