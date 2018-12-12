//
//  GFLocalAuthentication.swift
//
//  Created by Gualtiero Frigerio on 28/09/2018.
//

public enum GFLocalAuthenticationBiometricType {
    case biometricTypeNone
    case biometricTypeTouchID
    case biometricTypeFaceID
}

public class GFLocalAuthentication {
    
    var keychainService:String?
    var keychainGroup:String?
    var keychainWrapper:GFKeychainWrapper?
    
    public init() {
        
    }
    
    public func configureKeychain(service:String, group:String?) {
        self.keychainService = service
        self.keychainGroup = group
        self.keychainWrapper = GFKeychainWrapper(service: service, accessGroup: group)
    }
    
    public func getPasswordFromKeychain(account:String) -> String? {
        if let wrapper = self.keychainWrapper {
            do {
                let password = try wrapper.getPassword(forAccount: account)
                return password
            }
            catch {
                print("error while retrieving password for account \(account)")
            }
        }
        return nil
    }
    
    public func addItemInKeychain(account:String, password:String) -> Bool {
        if let wrapper = self.keychainWrapper {
            return wrapper.setPassword(password: password, forAccount: account)
        }
        return false
    }
    
    public func attempBiometricAuthentication(reason:String, revertToPasscode:Bool, callback: @escaping((Bool) -> Void)) {
        if #available(iOS 9.0, *) {
            let biometricAuthentication = GFBiometricAuthentication()
            let options = ["reason" : reason, "revertToPasscode" : revertToPasscode] as [String : Any]
            biometricAuthentication.attempBiometricAuthentication(options: options) { (status) in
                var returnValue = false
                if status == .biometricSuccess {
                    returnValue = true
                }
                callback(returnValue)
            }
        }
        else {
            callback(false)
        }
    }
    
    public func isBiometricAuthenticationAvailable() -> (available: Bool, type: GFLocalAuthenticationBiometricType) {
        if #available(iOS 9.0, *) {
            return GFBiometricAuthentication.isBiometricAuthenticationAvailable()
        } else {
            return (false, .biometricTypeNone)
        }
    }
}
