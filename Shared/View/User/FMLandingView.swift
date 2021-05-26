//
//  FMLandingView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 15/05/21.
//

import SwiftUI

struct FMLandingView: View {
    
    @EnvironmentObject private var hud: FMHudState

    @StateObject private var authenticationService = FMAuthenticationService.shared
    @State private var shouldPresentSignupForm = false
    @State private var shouldPresentLoginForm = false
    @State private var shouldPresentForgotPasswordForm = false
    
    var body: some View {
        if authenticationService.user != nil {
            FMTabView()
                .accentColor(AppSettings.appPrimaryColour)
        } else {
            GeometryReader { geo in
                ZStack {
                    VStack(spacing: 25) {
                        VStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100, alignment: .center)
                                .padding()
                                .foregroundColor(AppSettings.appPrimaryColour)
                                
                            Text("Hi, Welcome!")
                                .font(.title)
                                .bold()
                            Text("Click Login if you have account already, else click Register to create new account")
                                .font(.body)
                                .bold()
                                .foregroundColor(.secondary)
                                .padding()
                                .multilineTextAlignment(.center)
                        }
                        
                        .frame(width: geo.size.width - 30, height: geo.size.height * 0.5, alignment: .center)
                        Spacer()
                        FMButton(title: "Login", type: .secondary) {
                            shouldPresentLoginForm.toggle()
                        }
                        FMButton(title: "Register", type: .primary) {
                            shouldPresentSignupForm.toggle()
                        }
                        Button("Forgot Password?") {
                            shouldPresentForgotPasswordForm.toggle()
                        }
                        .padding()
                        .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .ignoresSafeArea(.keyboard)
            .popup(isPresented: $shouldPresentLoginForm, overlayView: {
                BottomPopupView(title: "Login", shouldDismiss: $shouldPresentLoginForm) {
                    FMSignupView(shouldPresentSignupForm: $shouldPresentLoginForm, type: .login)
                }
            })
            .popup(isPresented: $shouldPresentSignupForm, overlayView: {
                BottomPopupView(title: "Signup", shouldDismiss: $shouldPresentSignupForm) {
                    FMSignupView(shouldPresentSignupForm: $shouldPresentSignupForm, type: .signup)
                }
            })
            .popup(isPresented: $shouldPresentForgotPasswordForm, overlayView: {
                BottomPopupView(title: "Rest Password", shouldDismiss: $shouldPresentForgotPasswordForm) {
                    FMSignupView(shouldPresentSignupForm: $shouldPresentForgotPasswordForm, type: .resetPassword)
                }
            })
            .accentColor(AppSettings.appPrimaryColour)
        }
    }
}

struct FMLandingView_Previews: PreviewProvider {
    static var previews: some View {
        FMLandingView()
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
