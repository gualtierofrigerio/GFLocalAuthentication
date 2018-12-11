//
//  GFLocalAuthentication.swift
//
//  Created by Gualtiero Frigerio on 28/09/2018.
//

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
}
