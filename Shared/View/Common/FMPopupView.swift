//
//  FMPopupView.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 27/05/21.
//

import Foundation
import SwiftUI

struct BottomPopupView<Content: View>: View {
    
    @Environment(\.colorScheme) var colorScheme
    let title: String
    @Binding var shouldDismiss: Bool
    @ViewBuilder var content: () -> Content
    
    @State private var childSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack {
                    HStack {
                        Text(title)
                            .bold()
                            .font(.title3)
                        Spacer()
                        Button {
                            hideKeyboard()
                            withAnimation {
                                shouldDismiss.toggle()
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .frame(width: 25, height: 25, alignment: .center)
                                .foregroundColor(AppSettings.appSecondaryColour)
                        }

                    }
                    .padding([.top, .horizontal])
                    ScrollView {
                        content()
                            .childSize { size in
                                childSize = size
                            }
                    }
                    .frame(height: min(childSize.height, UIScreen.main.bounds.height * 0.60), alignment: .center)
                }
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                .background(colorScheme == .dark ? Color.black : Color.white)
                .cornerRadius(radius: 16, corners: [.topLeft, .topRight])
                .shadow(color: .secondary.opacity(0.5), radius: 10)
            }
            .edgesIgnoringSafeArea([.bottom])
        }
        .animation(.spring())
        .transition(.move(edge: .bottom))
    }
}

struct OverlayModifier<OverlayView: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    @ViewBuilder var overlayView: () -> OverlayView
    
    init(isPresented: Binding<Bool>, @ViewBuilder overlayView: @escaping () -> OverlayView) {
        self._isPresented = isPresented
        self.overlayView = overlayView
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(isPresented ? overlayView() : nil)
    }
    
}

struct RoundedCornersShape: Shape {
    
    let radius: CGFloat
    let corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    
    func cornerRadius(radius: CGFloat, corners: UIRectCorner = .allCorners) -> some View {
        clipShape(RoundedCornersShape(radius: radius, corners: corners))
    }
    
}

extension View {
    
    func popup<OverlayView: View>(isPresented: Binding<Bool>,
                                  blurRadius: CGFloat = 3,
                                  blurAnimation: Animation? = nil,
                                  @ViewBuilder overlayView: @escaping () -> OverlayView) -> some View {
        disabled(isPresented.wrappedValue) // Disable user interaction when the bottom popup is active
            .blur(radius: isPresented.wrappedValue ? blurRadius : 0)
            .animation(blurAnimation)
            .allowsHitTesting(!isPresented.wrappedValue)
            .modifier(OverlayModifier(isPresented: isPresented, overlayView: overlayView))
    }
    
}
