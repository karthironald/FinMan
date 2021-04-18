//
//  FMAddIncomeview.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 10/04/21.
//

import SwiftUI

struct FMAddIncomeview: View {
    @State var value: String = ""
    @State var frequencyIndex: Int = 0
    @State var comments: String = " "
    
    @ObservedObject var viewModel: FMIncomeViewModel
    @Binding var shouldPresentAddIncomeView: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Value")) {
                    TextField("value", text: $value)
                        .keyboardType(.numbersAndPunctuation)
                }
                Section(header: Text("Frequency")) {
                    Picker("Frequency", selection: $frequencyIndex) {
                        ForEach(0..<FMIncome.Frequency.allCases.count, id: \.self) { freq in
                            Text("\(FMIncome.Frequency.allCases[freq].title)")
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                }
                Section(header: Text("Additional comments")) {
                    TextEditor(text: $comments)
                        .frame(height: 100, alignment: .center)
                }
            }
            .navigationBarTitle(Text("Add Income"), displayMode: .inline)
            .navigationBarItems(trailing:
                                    Button("Save") {
                                        let newIncome = FMIncome(id: UUID(), value: Double(value) ?? 0.0, frequency: FMIncome.Frequency.allCases[frequencyIndex])
                                        viewModel.addNew(income: newIncome)
                                        shouldPresentAddIncomeView.toggle()
                                    }
            )
        }
    }
}

struct FMAddIncomeview_Previews: PreviewProvider {
    static var previews: some View {
        FMAddIncomeview(value: "16000", frequencyIndex: 0, comments: " ", viewModel: FMIncomeViewModel(), shouldPresentAddIncomeView: .constant(false))
    }
}
