//
//  FMLoadingInfoState.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 25/05/21.
//

import SwiftUI

final class FMLoadingInfoState: ObservableObject {
    
    @Published var isPresented: Bool = false
    @Published private(set) var shouldShowLoading: Bool = false
    
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
    
    func startLoading() {
        shouldShowLoading = true
    }
    
    func stopLoading() {
        shouldShowLoading = false
    }
    
}

extension FMLoadingInfoState {
    
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

