//
//  GFBiometricAuthentication.swift
//  FBSnapshotTestCase
//
//  Created by Gualtiero Frigerio on 12/12/2018.
//

import Foundation
import LocalAuthentication

enum GFBiometricAuthStatus {
    case biometricNotAvailable
    case biometricFailed
    case biometricSuccess
}

@available(iOS 9.0, *)
class GFBiometricAuthentication {
    
    let defaultReason = "Login to your account"
    
    func attempBiometricAuthentication(options:[String:Any], callback:@escaping ((GFBiometricAuthStatus) -> Void)) {
        let context = LAContext()
        var error: NSError?
        var policy = LAPolicy.deviceOwnerAuthentication
        let revert = options["revertToPasscode"] as! Bool
        if revert == false {
            policy = .deviceOwnerAuthenticationWithBiometrics
        }
        if context.canEvaluatePolicy(policy, error: &error) {
            var reason = defaultReason
            if let r = options["reason"] as? String {
                reason = r
            }
            context.evaluatePolicy(policy, localizedReason: reason) { (success, error) in
                if (success) {
                    callback(.biometricSuccess)
                }
                else {
                    callback(.biometricFailed)
                }
            }
        }
        else {
            // cannot use biometric
            callback(.biometricNotAvailable)
        }
    }
    
    static func isBiometricAuthenticationAvailable() -> (available:Bool, type: GFLocalAuthenticationBiometricType) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            if #available(iOS 11.0, *) {
                if context.biometryType == .faceID {
                    return (true, .biometricTypeFaceID)
                }
                else {
                    return (true, .biometricTypeTouchID)
                }
            } else { // we can only have TouchID on iOS < 11
                return (true, .biometricTypeTouchID)
            }
        }
        else {
            return (false, .biometricTypeNone)
        }
    }
}
