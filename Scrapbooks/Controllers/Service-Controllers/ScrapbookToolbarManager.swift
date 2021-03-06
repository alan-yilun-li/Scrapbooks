//
//  ScrapbookToolbarManager.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-09-06.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import UIKit

/// Class for managing the toolbar's state for a scrapbook's table of contents view (MomentTableViewController) 
/// - Note: Subclasses NSObject for key-value observing functionality.
class ScrapbookToolbarManager: NSObject {
    
    weak var momentTableToManage: MomentTableViewController!
    
    var toolbar: UIToolbar! {
        get {
            return (momentTableToManage?.navigationController?.toolbar)
        }
    }
    
    var scrapbook: Scrapbook! {
        get {
            return momentTableToManage?.scrapbook
        }
    }
    
    init(forMomentTable tableController: MomentTableViewController) {
        self.momentTableToManage = tableController
        super.init()
        
        regularModeToolbarSetup(withLockStatus: scrapbook.isLocked)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLockIcon), name: NSNotification.Name(LocalNotificationKeys.lockChangedNotifKey), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Updating the lock icon based on local notifications
    @objc func updateLockIcon() {
        regularModeToolbarSetup(withLockStatus: scrapbook.isLocked)
    }
    
    /// Contains code that sets up the UIToolBar for when the viewcontroller is not in editing mode
    func regularModeToolbarSetup(withLockStatus lock: Bool) {
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        // Maybe there can be an import feature added here in the future too... for people to import photos en masse and add captions one by one.
        
        let lockingButton: UIBarButtonItem!
        
        if lock {
            lockingButton = UIBarButtonItem(image: #imageLiteral(resourceName: "UnlockIcon"), style: .plain, target: momentTableToManage, action: #selector(self.momentTableToManage.removeLock))
        } else {
            lockingButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LockIcon"), style: .plain, target: momentTableToManage, action: #selector(self.momentTableToManage.addLock))
        }
        
        let editButtonItem = momentTableToManage.editButtonItem
        
        momentTableToManage.setToolbarItems([space, lockingButton, space, editButtonItem], animated: true)
    }

    
    /// Contains code that sets up the UIToolBar for when the viewcontroller is in editing mode
    func editingModeToolbarSetup() {
        
        let deleteScrapbookButton = UIBarButtonItem(barButtonSystemItem: .trash, target: momentTableToManage, action: #selector(self.momentTableToManage.trashScrapbook))
        
        let addCoverPhotoButton = UIBarButtonItem(title: "Edit Cover-Photo", style: .plain, target: momentTableToManage, action: #selector(self.momentTableToManage.selectCoverPhoto))
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        // Maybe there can be an import feature added here in the future too... for people to import photos en masse and add captions one by one.
        
        momentTableToManage.setToolbarItems([deleteScrapbookButton, space, addCoverPhotoButton, space, momentTableToManage.editButtonItem], animated: true)
    }

    
}
