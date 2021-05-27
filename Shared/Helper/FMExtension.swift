//
//  FMExtension.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/05/21.
//

import Foundation
import SwiftUI

protocol Dated {
    var createdDate: Date { get }
}

extension Array where Element: Dated {
    
    func groupedBy(dateComponents: Set<Calendar.Component>) -> [String: [Element]] {
        let initial: [String: [Element]] = [:]
        let groupedByDateComponents = reduce(into: initial) { acc, cur in
            let components = Calendar.current.dateComponents(dateComponents, from: cur.createdDate)
            let date = Calendar.current.date(from: components)!
            
            let df = DateFormatter()
            df.dateFormat = "yyyy MMM"
            
            let dString = df.string(from: date)
            let existing = acc[dString] ?? []
            acc[dString] = existing + [cur]
        }
        
        return groupedByDateComponents
    }
    
}

struct FMButton: View {
    var title: String
    var type: ButtonType = .primary
    var action: () -> ()
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            HStack {
                Spacer()
                Text(title)
                Spacer()
            }
        })
        .modifier(FMButtonThemeModifier(type: type))
    }
    
    enum ButtonType {
        case primary, secondary
    }
}

struct FMButtonThemeModifier: ViewModifier {
    var type: FMButton.ButtonType
    
    func body(content: Content) -> some View {
        content
            .frame(height: 50, alignment: .center)
            .background((type == .primary) ? AppSettings.appPrimaryColour : AppSettings.appSecondaryColour)
            .foregroundColor((type == .primary) ? .white : AppSettings.appPrimaryColour)
            .cornerRadius(AppSettings.appCornerRadius)
    }
}

struct FMTextField: View {
    var title: String
    var keyboardType: UIKeyboardType = .default
    
    @Binding var value: String
    @Binding var infoMessage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            TextField(title, text: $value)
                .modifier(FMTextFieldThemeModifier(keyboardType: keyboardType))
            if !infoMessage.isEmpty {
                Text(infoMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
        
    }
}

struct FMTextFieldThemeModifier: ViewModifier {
    var keyboardType: UIKeyboardType
    
    func body(content: Content) -> some View {
        content
            .font(.body)
            .padding()
            .frame(height: 50, alignment: .center)
            .background(AppSettings.appSecondaryColour)
            .cornerRadius(AppSettings.appCornerRadius)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .keyboardType(keyboardType)
    }
}

struct FMTextEditorThemeModifier: ViewModifier {
    var keyboardType: UIKeyboardType
    
    func body(content: Content) -> some View {
        content
            .font(.body)
            .padding()
            .frame(height: 100, alignment: .center)
            .background(AppSettings.appSecondaryColour)
            .cornerRadius(AppSettings.appCornerRadius)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .keyboardType(keyboardType)
    }
}

extension View {
    
    func closeButtonView(actionBlock: @escaping () -> ()) -> some View {
        Button(action: {
            actionBlock()
        }, label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title3)
        })
        .foregroundColor(.secondary)
    }
    
    func startLoading(start: Bool) -> some View {
        Group {        
            if start {
                ZStack {
                    self
                    RoundedRectangle(cornerRadius: AppSettings.appCornerRadius)
                        .fill(AppSettings.appPrimaryColour)
                        .frame(width: 100, height: 75, alignment: .center)
                        .overlay(
                            ProgressView("Loading...")
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                        .foregroundColor(.white)
                }
            } else {
                self
            }
        }
    }
    
}

#if canImport(UIKit)
extension View {
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}
#endif
