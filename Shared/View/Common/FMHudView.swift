//
//  FMHudView.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 27/05/21.
//

import Foundation
import SwiftUI

struct FMHud<Content: View>: View {
    
    var hudType: FMLoadingInfoState.HudType
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .foregroundColor(.white)
            .padding(10)
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
    
    func hud<Content: View>(isPresented: Binding<Bool>, type: FMLoadingInfoState.HudType = .info, @ViewBuilder content: () -> Content) -> some View {
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
                .font(.title3)
            configuration.title
        }
    }
    
}
