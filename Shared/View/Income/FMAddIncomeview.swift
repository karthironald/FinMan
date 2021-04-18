//
//  FMAddIncomeview.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 10/04/21.
//

import SwiftUI

struct FMAddIncomeview: View {
    @State var value: String = ""
    @State var frequency: String = ""
    @State var comments: String = " "
    
    @Binding var shouldPresentAddIncomeView: Bool
    
    var body: some View {
        Form {
            Section {
                TextField("value", text: $value)
            }
            Section {
                Picker("Frequency", selection: $frequency) {
                    ForEach(0..<FMIncome.Frequency.allCases.count, id: \.self) { freq in
                        Text("\(FMIncome.Frequency.allCases[freq].rawValue)")
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            Section {
                TextEditor(text: $comments)
            }
        }
    }
}

struct FMAddIncomeview_Previews: PreviewProvider {
    static var previews: some View {
        FMAddIncomeview(value: "16000", frequency: FMIncome.Frequency.onetime.rawValue, comments: "Sample", shouldPresentAddIncomeView: .constant(false))
    }
}
