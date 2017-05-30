//
//  UITableView+PCKeyedHeightCache.swift
//  SwiftTableViewHeightCache
//
//  Created by tangyuhua on 2017/5/28.
//  Copyright © 2017年 tangyuhua. All rights reserved.
//

import UIKit


//MARK: Cache by key
extension UITableView {
    func pc_heightForCell(withIdentifier identifier: String,
                          cacheKey key:AnyHashable,configuration:@escaping ConfigureBlock) -> CGFloat {
        if pc_keyedHeightCache.existsHeightFor(key) {
            let cachedHeight = pc_keyedHeightCache.heightFor(key)
            pc_debugLog("hit cache by key[\(key)] - \(cachedHeight)")
            return cachedHeight
        }
        
        let height = pc_heightForCell(withIdentifier: identifier, configure: configuration)
        pc_keyedHeightCache .cache(height, by: key)
        pc_debugLog("cached by key[\(key)] - \(height)")
        return height
    }
    
    
    
}

private var keyedHeightCachekey: Void?
extension UITableView {
    var pc_keyedHeightCache: PCKeyedHeightCache {
        get {
            return objc_getAssociatedObject(self, &keyedHeightCachekey) as? PCKeyedHeightCache ?? PCKeyedHeightCache()
        }
        set(newValue) {
            objc_setAssociatedObject(self, &keyedHeightCachekey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

class  PCKeyedHeightCache {
    var mutableHeightsByKeyForPortrait: [AnyHashable:CGFloat]
    var mutableHeightsByKeyForLandscape: [AnyHashable:CGFloat]
    
    var mutableHeightsByKeyForCurrentOrientation: [AnyHashable:CGFloat] {
        get {
            return UIDevice.current.orientation.isLandscape ? mutableHeightsByKeyForPortrait: mutableHeightsByKeyForPortrait
        }
        
    }
    
    init() {
        mutableHeightsByKeyForPortrait = [:]
        mutableHeightsByKeyForLandscape = [:]
    }
    
    
    
    func existsHeightFor(_ key: AnyHashable) -> Bool {
        let key =  mutableHeightsByKeyForCurrentOrientation[key]
        return (key != nil) && (key == -1)
    }
    
    func cache(_ height: CGFloat, by key:AnyHashable) {
        if UIDevice.current.orientation.isLandscape {
            mutableHeightsByKeyForPortrait[key] = height
        } else {
            mutableHeightsByKeyForPortrait[key] = height
        }
    }
    
    func heightFor(_ key: AnyHashable) -> CGFloat {
        return mutableHeightsByKeyForCurrentOrientation[key]!
    }
    
    func invalidateHeightFor(_ key: AnyHashable) {
        mutableHeightsByKeyForPortrait.removeValue(forKey: key)
        mutableHeightsByKeyForLandscape.removeValue(forKey: key)
    }
    
    func invalidateAllHeightCache() {
        mutableHeightsByKeyForLandscape.removeAll()
        mutableHeightsByKeyForPortrait.removeAll()
    }
    
}

