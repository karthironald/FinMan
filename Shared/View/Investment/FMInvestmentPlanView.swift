//
//  FMInvestmentPlanView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 12/06/21.
//

import SwiftUI

struct FMInvestmentPlanView: View {
    @AppStorage("total") var total: String = ""
    @State var investments: [FMInvestment] = []
    @AppStorage("investmentsData") private var investmentsData: Data = Data()
    @State var balance: Double = 0.0
    @State var shouldAddInvestment = false
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Total")
                        Spacer()
                        TextField("Total", text: $total)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: total, perform: { value in
                                updateBalance()
                            })
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("Balance")
                        Spacer()
                        Text("(\(FMHelper.percentage(of: balance, in: Double(total) ?? 0.0).localCurrencyString() ?? "-")%")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text(balance.localCurrencyString() ?? "-")
                    }
                    .foregroundColor(.secondary)
                }
                Section {
                    Button("Add New") {
                        let newInvestment = FMInvestment(name: "", absoluteValue: 0.0)
                        investments.insert(newInvestment, at: 0)
                    }
                    .disabled((Double(total) ?? 0.0) <= 0.0)
                    ForEach(investments) { investment in
                        let b = Binding {
                            investment
                        } set: { newValue in
                            if let index = investments.firstIndex(where: { $0.id == newValue.id }) {
                                investments[index] = newValue
                                updateBalance()
                            }
                            if let data = try? JSONEncoder().encode(investments) {
                                investmentsData = data
                            }
                        }
                        FMInvestmentPlanRowView(total: Double(total) ?? 0.0, investment: b)
                    }
                    .onDelete(perform: { indexSet in
                        if let index = indexSet.first {
                            investments.remove(at: index)
                            updateBalance()
                            saveInvestments()
                        }
                    })
                }
            }
            .onAppear(perform: {
                if let savedInvestments = try? JSONDecoder().decode([FMInvestment].self, from: investmentsData) {
                    investments = savedInvestments
                    updateBalance()
                }
            })
            .onDisappear(perform: {
                saveInvestments()
            })
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Budget")
        }
    }
    
    
    // MARK: - Custom methods
    
    func balanceValue() -> Double {
        let totalInvestments = investments.reduce(0, { $0 + $1.absoluteValue })
        return (Double(total) ?? 0.0) - totalInvestments
    }
    
    func saveInvestments() {
        if let data = try? JSONEncoder().encode(investments) {
            investmentsData = data
        }
    }
    
    func updateBalance() {
        balance = balanceValue()
    }
    
}

struct FMInvestmentPlanView_Previews: PreviewProvider {
    
    static var previews: some View {
        FMInvestmentPlanView(total: "73000", investments: FMInvestment.samepleData)
    }
    
}

class FMInvestment: Identifiable, ObservableObject, Codable {
    var id = UUID()
    @Published var name: String = ""
    @Published var absoluteValue: Double = 0.0
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case absoluteValue
    }
    
    
    // MARK: - Init Methods
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        id = try container.decode(UUID.self, forKey: .id)
        absoluteValue = try container.decode(Double.self, forKey: .absoluteValue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(id, forKey: .id)
        try container.encode(absoluteValue, forKey: .absoluteValue)
    }
    
    init(name: String, absoluteValue: Double) {
        self.name = name
        self.absoluteValue = absoluteValue
    }
    
    static let samepleData = [FMInvestment(name: "PPF", absoluteValue: 7000), FMInvestment(name: "NPS", absoluteValue: 5000), FMInvestment(name: "Mutual Funds", absoluteValue: 5000), FMInvestment(name: "Stocks", absoluteValue: 2000), FMInvestment(name: "Car loan", absoluteValue: 25000)]
}


