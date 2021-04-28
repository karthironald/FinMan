//
//  FMAddIncomeview.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 10/04/21.
//

import SwiftUI

struct FMAddIncomeview: View {
    @State var value: String = ""
    @State var frequency: FMIncome.Frequency = .onetime
    @State var source: FMIncome.Source = .earned
    @State var comments: String = ""
    
    var viewModel: FMIncomeListViewModel? = nil
    var incomeRowViewModel: FMIncomeRowViewModel? = nil
    @Binding var shouldPresentAddIncomeView: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Enter amount value", text: $value)
                        .keyboardType(.decimalPad)
                }
                Section(footer: Text("\(source.info)").padding(.leading)) {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(FMIncome.Frequency.allCases, id: \.self) { freq in
                            Text("\(freq.title)")
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                    Picker("Source", selection: $source) {
                        ForEach(FMIncome.Source.allCases, id: \.self) { source in
                            Text("\(source.title)")
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                }

                Section {
                    ZStack(alignment: .topLeading) {
                        if comments.isEmpty {
                            Text("Enter additional comments(if any)")
                                .foregroundColor(.secondary)
                                .opacity(0.5)
                                .padding([.top, .leading], 5)
                        }
                        TextEditor(text: $comments)
                            .frame(height: 100, alignment: .center)
                    }
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
            let income = FMIncome(value: Double(value) ?? 0.0, frequency: frequency.rawValue, source: source.rawValue, comments: comments)
            viewModel?.addNew(income: income)
        } else {
            if let income = incomeRowViewModel?.income {
                var updatedIncome = income
                updatedIncome.value = Double(value) ?? 0.0
                updatedIncome.frequency = frequency.rawValue
                updatedIncome.source = source.rawValue
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
