//
//  FMHelper.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 15/05/21.
//

import Foundation

class FMHelper {
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
}
