//
//  LockingManager.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-09-05.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import LocalAuthentication
import UIKit

struct LockingManager {
    
    static var shared = LockingManager()
    
    var delegate: LockingManagerDelegate?
    
    private init() {
        
    }
    
    /// Function that prompts the user for touch ID input.
    /// - Returns: True if authentication succeeded, and false otherwise.
    func promptForID() {
        
        guard let responder = delegate else {
            print("no delegate object to accept response")
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "This scrapbook is locked! Please authenticate with Touch ID.", reply: { (success, error) in
                
                if success {
                    responder.authenticationFinished(withSuccess: true)
                }
                
                if (error != nil) {
                    responder.authenticationFinished(withSuccess: false)
                    print("error")
                }
                
            })
        }
        
    }
    
    func addLock(forScrapbook scrapbook: Scrapbook) {
        
        scrapbook.isLocked = true
        CoreDataStack.shared.saveContext()
    }
    
    
    func removeLock(forScrapbook scrapbook: Scrapbook) {
        
        scrapbook.isLocked = false
        CoreDataStack.shared.saveContext()
    }
    
    
}

/// Protocol for an object which responds to the locking manager.
protocol LockingManagerDelegate {
    
    func authenticationFinished(withSuccess success: Bool)
    
}


extension UIViewController: LockingManagerDelegate {
    
    
    func authenticationFinished(withSuccess success: Bool) {
        
        if success {
            return
        } else {
            let response = UIAlertController(title: "Authentication Failed", message: "Please try again.", preferredStyle: .alert)
            response.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(response, animated: true)
        }
    }
}

