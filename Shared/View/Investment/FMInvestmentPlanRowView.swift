//
//  FMInvestmentPlanRowView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 12/06/21.
//

import SwiftUI

struct FMInvestmentPlanRowView: View {
    
    var total: Double
    @Binding var investment: FMInvestment
    
    
    // MARK: - View Body
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                TextField("Name", text: $investment.name)
                Spacer()
                Text("(\(FMHelper.percentage(of: investment.absoluteValue, in: total), specifier: "%0.2f")%)")
                    .foregroundColor(.secondary)
                    .font(.caption)
                Text("\(Int(investment.absoluteValue))")
            }
            Slider(value: $investment.absoluteValue, in: 0...max(total, investment.absoluteValue), step: 500)
        }
        .padding(.vertical, 5)
    }
    
}

struct FMInvestmentPlanRowView_Previews: PreviewProvider {
    static var previews: some View {
        FMInvestmentPlanRowView(total: 75000, investment: .constant(FMInvestment.samepleData.first!))
    }
}
