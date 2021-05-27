//
//  FMPopupView.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 27/05/21.
//

import Foundation
import SwiftUI

struct BottomPopupView<Content: View>: View {
    
    let title: String
    @Binding var shouldDismiss: Bool
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack {
                    HStack {
                        Text(title)
                            .bold()
                            .font(.title)
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
                    content()
                }
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                .background(Color.white)
                .cornerRadius(radius: 16, corners: [.topLeft, .topRight])
                .shadow(radius: 10)
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
                                  blurAnimation: Animation? = .linear,
                                  @ViewBuilder overlayView: @escaping () -> OverlayView) -> some View {
        blur(radius: isPresented.wrappedValue ? blurRadius : 0)
            .animation(blurAnimation)
            .allowsHitTesting(!isPresented.wrappedValue)
            .modifier(OverlayModifier(isPresented: isPresented, overlayView: overlayView))
    }
    
}
