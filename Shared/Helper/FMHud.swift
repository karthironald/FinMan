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
    
    func show(title: String, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
        withAnimation {
            isPresented = true
        }
    }
    
}

struct FMHud<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .padding(.horizontal)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppSettings.appCornerRadius)
                    .foregroundColor(Color.white)
                    .shadow(color: Color(.black).opacity(0.16), radius: 12, x: 0, y: 5)
            )
    }
}

struct FMHud_Previews: PreviewProvider {
    static var previews: some View {
        FMHud {
            Text("Sample")
        }
    }
}

extension View {
    
    func hud<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) -> some View {
        ZStack(alignment: .top) {
            self
            
            if isPresented.wrappedValue {
                FMHud(content: content)
                    .animation(.spring())
                    .transition(.move(edge: .top))
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
