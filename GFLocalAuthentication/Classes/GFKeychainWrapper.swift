//
//  GFKeychainWrapper.swift
//
//  Created by Gualtiero Frigerio on 28/09/2018.
//

import Foundation

enum GFKeychainError:Error {
    case noPassword
    case invalidPasswordData
    case invalidData
    case genericError(status: OSStatus)
}

struct GFKeychainItem {
    var account:String
    var password:String
    
    init(account:String, password:String) {
        self.account = account
        self.password = password
    }
}

class GFKeychainWrapper {
    
    let service: String
    let accessGroup: String?
    
    init(service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }
    
    func getAllItems() throws -> [GFKeychainItem] {
        return try! GFKeychainWrapper.getItems(forService: self.service, accessGroup: self.accessGroup, account: nil)
    }
    
    func getPassword(forAccount account:String) throws -> String? {
        let items = try GFKeychainWrapper.getItems(forService: self.service, accessGroup: self.accessGroup, account: account)
        if items.count > 0 {
            return items[0].password
        }
        return nil
    }
    
    func setPassword(password:String, forAccount account:String) -> Bool {
        do {
            let items = try GFKeychainWrapper.getItems(forService: self.service, accessGroup: self.accessGroup, account: account)
            if items.count > 0 {
                let query = GFKeychainWrapper.makeKeychainQuery(withService: self.service, accessGroup: self.accessGroup, account: account)
                let passwordData = password.data(using: String.Encoding.utf8)!
                var attributesToUpdate = [String : AnyObject]()
                attributesToUpdate[kSecValueData as String] = passwordData as AnyObject
                let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
                guard status == noErr else {
                    return false
                }
            }
            else {
                return setNewItem(account: account, password: password)
            }
        }
        catch {
            return setNewItem(account: account, password: password)
        }
        return true
    }
    
    static func getItems(forService service:String, accessGroup:String? = nil, account:String? = nil) throws -> [GFKeychainItem] {
        var query = GFKeychainWrapper.makeKeychainQuery(withService: service, accessGroup: accessGroup, account:account)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard status != errSecItemNotFound else {
            return []
        }
        
        guard status == noErr else {
            throw GFKeychainError.genericError(status: status)
        }
        
        guard let resultSingleData = queryResult as? [String : Any] else {
            throw GFKeychainError.invalidData
        }
        
        let resultData:[[String:Any]] = [resultSingleData]
        
        var items = [GFKeychainItem]()
        for result in resultData {
            guard let accountValue  = result[kSecAttrAccount as String] as? String else {
                throw GFKeychainError.invalidData
            }
            guard let passwordData = result[kSecValueData as String] as? Data,
                  let passwordValue = String(data: passwordData, encoding: String.Encoding.utf8) else {
                throw GFKeychainError.invalidPasswordData
            }
            
            let item = GFKeychainItem(account: accountValue, password:passwordValue)
            items.append(item)
        }
        
        return items
    }
    
    private func setNewItem(account:String, password:String) -> Bool {
        let passwordData = password.data(using: String.Encoding.utf8)!
        var newItem = GFKeychainWrapper.makeKeychainQuery(withService: self.service, accessGroup: self.accessGroup, account: account)
        newItem[kSecValueData as String] = passwordData as AnyObject
        
        let status = SecItemAdd(newItem as CFDictionary, nil)
        guard status == noErr else {
            return false
        }
        return true
    }
    
    private static func makeKeychainQuery(withService service: String, accessGroup: String? = nil, account: String? = nil) -> [String : AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
}
