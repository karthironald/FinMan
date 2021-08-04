//
//  FMButton.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 31/07/21.
//

import Foundation
import SwiftUI

struct FMButton: View {
    
    var title: String
    var type: ButtonType = .primary
    var shouldShowLoading: Bool = false
    
    var action: () -> ()
    
    var body: some View {
        ZStack {
            Button(action: {
                hideKeyboard()
                action()
            }, label: {
                HStack {
                    Spacer()
                    Text(title)
                    Spacer()
                }
                .opacity(shouldShowLoading ? 0 : 1)
            })
            .modifier(FMButtonThemeModifier(type: type))
            if shouldShowLoading {
                FMDotsLoading()
            }
        }
    }
    
}


extension FMButton {
    
    enum ButtonType {
        case primary, secondary, logout
        
        var backgroundColor: Color {
            switch self {
            case .primary: return AppSettings.appPrimaryColour
            case .secondary: return AppSettings.appSecondaryColour
            case .logout: return Color.red.opacity(0.1)
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return AppSettings.appPrimaryColour
            case .logout: return Color.red
            }
        }
    }
    
}

struct FMButtonThemeModifier: ViewModifier {
    
    var type: FMButton.ButtonType
    @Environment(\.isEnabled) var isEnabled
    
    func body(content: Content) -> some View {
        content
            .frame(height: 50, alignment: .center)
            .background(!isEnabled ? Color.gray.opacity(0.5) : type.backgroundColor)
            .foregroundColor(!isEnabled ? Color.secondary : type.foregroundColor)
            .cornerRadius(AppSettings.appCornerRadius)
    }
    
}
