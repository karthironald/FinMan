//
//  FMTextField.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 31/07/21.
//

import Foundation
import SwiftUI

struct FMTextField: View {
   
    var title: String
    var keyboardType: UIKeyboardType = .default
    var height: CGFloat = 50
    
    @Binding var value: String
    @Binding var infoMessage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            TextField(title, text: $value)
                .modifier(FMTextFieldThemeModifier(keyboardType: keyboardType, height: height))
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
    var height: CGFloat = 50
    
    func body(content: Content) -> some View {
        content
            .font(.body)
            .padding()
            .frame(height: height, alignment: .center)
            .background(Color.secondary.opacity(0.12))
            .cornerRadius(AppSettings.appCornerRadius)
            .keyboardType(keyboardType)
    }
    
}

struct FMTextEditorThemeModifier: ViewModifier {
    
    var keyboardType: UIKeyboardType
    var height: CGFloat = 100
    
    func body(content: Content) -> some View {
        content
            .font(.body)
            .padding()
            .frame(height: height, alignment: .center)
            .background(Color.secondary.opacity(0.12))
            .cornerRadius(AppSettings.appCornerRadius)
            .keyboardType(keyboardType)
    }
    
}
