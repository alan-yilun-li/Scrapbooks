//
//  Scrapbook+CoreDataClass.swift
//  Scrapbooks
//
//  Created by Dev User on 2017-07-24.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import CoreData
import UIKit


public class Scrapbook: NSManagedObject {
    
    var fileDirectory: String {
        get {
            let documentDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first
            return (documentDirectory?.appendingPathComponent(name).path)!
        }
    }
    
    private var coverPhotoLocation: URL {
        get {
            return URL(fileURLWithPath: fileDirectory).appendingPathComponent("cover-photo/cover-image.png", isDirectory: false)
        }
    }
    
    var coverPhoto: UIImage? {

        get {
            do {
                let imageData = try Data(contentsOf: coverPhotoLocation)
                return UIImage(data: imageData)!
            } catch (let error) {
                print("Retrieve cover photo failed: \(String(describing: error)) for location: \(coverPhotoLocation)")
                return nil
            }
        }
    
        set {
            do {
                print("setting cover image to path \(coverPhotoLocation)")
                try UIImagePNGRepresentation(newValue!)!.write(to: coverPhotoLocation, options: [.atomic])
            } catch (let error) {
                print("error setting cover photo: \(error)")
            }
        }
    }
    
    func setup(withName newName: String) {
        name = newName
        moments = NSOrderedSet(array: [])
        
        do {
            let path = fileDirectory + "/cover-photo/"
            // Making the cover-photo directory and the base directory with one line
            try FileManager().createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch (let error) {
            print("Creating scrapbook failed: \(String(describing: error))")
            fatalError()
        }
    }
    
    
    /// Properly removes a moment by deleting its accompanying photo from the filesystem as well.
    /// - Note: This remove should be called before the automatic remove generated by Core Data unless special customization is needed.
    func properlyRemove(moment: Moment) {
        
        let name = moment.name
        FileSystemHelper.removeFromDisk(photoWithName: name, forScrapbook: self)
        removeFromMoments(moment)
        CoreDataStack.shared.persistentContainer.viewContext.delete(moment)
    }
}

extension Scrapbook: Named {} 


