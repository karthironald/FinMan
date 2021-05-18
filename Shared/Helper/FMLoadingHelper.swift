//
//  FMLoading.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 16/05/21.
//

import Foundation
import SwiftUI

class FMLoadingHelper: ObservableObject {
    
    static let shared = FMLoadingHelper()
    
    @Published var shouldShowLoading = false
    
    // MARK: - Init Methods
    private init() { }
}
