//
//  FMGridView.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/06/21.
//

import SwiftUI

struct FMGridView<Item: RawRepresentable>: View where Item.RawValue == String {
    
    let items: [Item]
    @Binding var selectedItem: Item
    @Binding var shouldDismiss: Bool
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        LazyVGrid(columns: columns, content: {
            ForEach(0..<items.count, id: \.self) { index in
                Text("\(items[index].rawValue.capitalized)")
                    .font(.caption)
                    .padding(10)
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 50, alignment: .center)
                    .background(selectedItem.rawValue == items[index].rawValue ? AppSettings.appPrimaryColour : AppSettings.appSecondaryColour)
                    .clipShape(Capsule())
                    .foregroundColor(selectedItem.rawValue == items[index].rawValue ? .white : .black)
                    .onTapGesture {
                        selectedItem = items[index]
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                shouldDismiss.toggle()
                            }
                        }
                    }
            }
        })
    }
}

struct FMCategoryGridView_Previews: PreviewProvider {
    static var previews: some View {
        FMGridView<FMTransaction.ExpenseCategory>(items: FMTransaction.ExpenseCategory.allCases, selectedItem: .constant(.clothing), shouldDismiss: .constant(false))
    }
}
