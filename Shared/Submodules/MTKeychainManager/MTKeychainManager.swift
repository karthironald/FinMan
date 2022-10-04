//
//  MTKeychainManager.swift
//  DigitalVault
//
//  Created by Karthick Selvaraj on 26/09/18.
//  Copyright © 2018 mallow. All rights reserved.
//

import UIKit

enum DALKeyChainType: CaseIterable {
    case currentUserMailId
    case currentUserPassword
    case rememberMeUserMailId
    case rememberMeUserPassword
    case accessToken
    case refreshToken
    
    var keyName: String {
        return String(describing: self)
    }
}

class MTKeychainManager: NSObject {

    static let sharedInstance = MTKeychainManager()
    
    var serviceName: String = Bundle.main.bundleIdentifier! // Service name is used to identify app's data in keychain. For maintaining uniqueness we are using bundle identifier as serviceName for keychain.
    
    
    // MARK: - Custom methods
    
    /**
     This methods saves the given value against given key in keychain
     
     - parameter value: Data what we are about to save in keychain.
     - parameter key: Unique key for Data what we are about to save in keychain for easy access in future
     
     - returns: True if data saved successfully. False if not saved successfully.
     */
    func save(value: String?, for keyType: DALKeyChainType?) -> Bool {
        if let value = value, let keyName = keyType?.keyName {
            do {
                try KeychainPasswordItem(service: serviceName, account: keyName).savePassword(value) // Save in Keychain.
                return true
            } catch {
                print(error)
            }
        }
        return false
    }
    
    
    /**
     This method will read the value for the given key
     
     - parameter key: Key for reading value from keychain which it associates
     
     - returns: Returns value for given key if available, else returns nil
     */
    func value(for keyType: DALKeyChainType?) -> String? {
        if let key = keyType?.keyName {
            do {
                let value = try KeychainPasswordItem(service: serviceName, account: key).readPassword() // Read value from Keychain.
                if value.count > 0 {
                    return value
                } else {
                    return nil
                }
            } catch {
                print(error)
            }
        }
        return nil
    }
    
    /**
     Delete the value for given key from Keychain
     
     - parameter key: Key for deleting its associated value
     
     - returns: Return true if successfully deleted, false if data is not deleted or unavailable to delete
     */
    func deleteValue(for keyType: DALKeyChainType?) -> Bool {
        if let key = keyType?.keyName {
            do {
                try KeychainPasswordItem(service: serviceName, account: key).deleteItem() // Delete data from keychain.
                return true
            } catch {
                print(error)
            }
        }
        return false
    }
    
    /**Delete all saved details from Keychain*/
    func deleteAllSavedData() {
        for key in DALKeyChainType.allCases { // Delete all keys
            _ = deleteValue(for: key)
        }
    }
    
}
