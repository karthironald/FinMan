//
//  FMHud.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 25/05/21.
//

import SwiftUI

final class FMHudState: ObservableObject {
    
    @Published var isPresented: Bool = false
    private(set) var title: String = ""
    private(set) var systemImage: String = ""
    private(set) var hudType: HudType = .info
    
    func show(title: String, systemImage: String? = nil, type: HudType = .info) {
        self.title = title
        self.systemImage = (systemImage != nil) ? systemImage! : type.defaultIconName
        self.hudType = type
        withAnimation {
            isPresented = true
        }
    }
    
}

extension FMHudState {
    
    enum HudType {
        case success, info, error
        
        var backgroundColor: Color {
            switch self {
            case .success: return Color.green
            case .info: return Color.orange
            case .error: return Color.red
            }
        }
        
        var defaultIconName: String {
            switch self {
            case .success: return "checkmark.circle"
            case .info: return "info.circle"
            case .error: return "xmark.circle"
            }
        }
    }
    
}

struct FMHud<Content: View>: View {
    
    var hudType: FMHudState.HudType
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: AppSettings.appCornerRadius)
                    .foregroundColor(hudType.backgroundColor)
                    .shadow(color: Color(.black).opacity(0.16), radius: 12, x: 0, y: 5)
            )
    }
}

struct FMHud_Previews: PreviewProvider {
    static var previews: some View {
        FMHud(hudType: .info) {
            Text("Sample")
        }
    }
}

extension View {
    
    func hud<Content: View>(isPresented: Binding<Bool>, type: FMHudState.HudType = .info, @ViewBuilder content: () -> Content) -> some View {
        ZStack(alignment: .top) {
            self
            
            if isPresented.wrappedValue {
                FMHud(hudType: type, content: content)
                    .animation(.spring())
                    .transition(.asymmetric(insertion: .move(edge: .top), removal: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isPresented.wrappedValue = false
                            }
                        }
                    }
                    .zIndex(1)
            }
        }
    }
    
}

struct CustomLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration
                .icon
                .font(.title)
            configuration.title
        }
    }
}
