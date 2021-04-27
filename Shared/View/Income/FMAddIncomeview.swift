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
    
    var viewModel: FMIncomeListViewModel? = nil
    var incomeRowViewModel: FMIncomeRowViewModel? = nil
    @Binding var shouldPresentAddIncomeView: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Value")) {
                    TextField("value", text: $value)
                        .keyboardType(.decimalPad)
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
                                        saveButtonTapped()
                                        shouldPresentAddIncomeView.toggle()
                                    }
            )
        }
    }
    
    func saveButtonTapped() {
        if incomeRowViewModel?.id == nil && viewModel != nil {
            let income = FMIncome(value: Double(value) ?? 0.0, frequency: frequencyIndex, comments: comments)
            viewModel?.addNew(income: income)
        } else {
            if let income = incomeRowViewModel?.income {
                var updatedIncome = income
                updatedIncome.value = Double(value) ?? 0.0
                updatedIncome.frequency = frequencyIndex
                updatedIncome.comments = comments
                incomeRowViewModel?.update(income: updatedIncome)
            }
        }
    }
}

struct FMAddIncomeview_Previews: PreviewProvider {
    static var previews: some View {
        FMAddIncomeview(viewModel: FMIncomeListViewModel(), shouldPresentAddIncomeView: .constant(false))
    }
}
