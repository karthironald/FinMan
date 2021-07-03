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
            df.dateFormat = "yyyy MM"
            
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

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
}

extension View {
    
    func childSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geoProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geoProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

#if canImport(UIKit)
extension View {
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}
#endif

struct FMDotsLoading: View {
    
    @State private var shouldAnimate = false
    let size: CGFloat = 10
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever())
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.3))
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.6))
        }
        .onAppear {
            self.shouldAnimate = true
        }
    }
    
}
