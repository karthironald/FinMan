//
//  FMDotLoading.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 31/07/21.
//

import Foundation
import SwiftUI

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
