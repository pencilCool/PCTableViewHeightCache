//
//  UITableView+PCIndexPathHeightCache.swift
//  SwiftTableViewHeightCache
//
//  Created by tangyuhua on 2017/5/28.
//  Copyright © 2017年 tangyuhua. All rights reserved.
//

import UIKit

//MARK: Cache by indexpath
private var indexPathHeightCacheKey: Void?


extension UITableView {
    var pc_indexPathHeightCache: PCIndexPathHeightCache {
        get {
            return objc_getAssociatedObject(self, &indexPathHeightCacheKey) as? PCIndexPathHeightCache ?? PCIndexPathHeightCache()
        }
        set(newValue) {
            objc_setAssociatedObject(self, &indexPathHeightCacheKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func pc_heightForCell(withIdentifier identifier:String, cacheBy indexPath: IndexPath, configure: ConfigureBlock) -> CGFloat {
        
        if pc_indexPathHeightCache.existsHeight(at: indexPath) {
            let height = pc_indexPathHeightCache.heightFor(indexPath)
            pc_debugLog("hit cache by index path[\(indexPath.section):\(indexPath.row)] - \(height)")
            return height
        }
        
        let height = pc_heightForCell(withIdentifier: identifier, configure:configure)
        pc_indexPathHeightCache.cacheHeight(height, by: indexPath)
        pc_debugLog("cached by index path[\(indexPath.section):\(indexPath.row)] - \(height)")
        return height
    }
    
    
}

class PCIndexPathHeightCache {

    typealias FDIndexPathHeightsBySection = [[CGFloat]]
    var heightsBySectionForPortrait  : FDIndexPathHeightsBySection
    var heightsBySectionForLandscape : FDIndexPathHeightsBySection
    
    var heightsBySectionForCurrentOrientation:FDIndexPathHeightsBySection {
        return UIDevice.current.orientation.isLandscape ? heightsBySectionForLandscape: heightsBySectionForPortrait
    }
    
    var automaticallyInvalidateEnabled:Bool
    
    init() {
        heightsBySectionForPortrait    = [[CGFloat]]()
        heightsBySectionForLandscape   = [[CGFloat]]()
        
        automaticallyInvalidateEnabled = false
    }
    
    func enumerateAllOrientations(using block:(_ heightsBySection: FDIndexPathHeightsBySection) ->()) {
        block(heightsBySectionForLandscape)
        block(heightsBySectionForPortrait)
    }
    
    func existsHeight(at indexPath: IndexPath) -> Bool{
        buildCachesAtIndexPathsIfNeeded([indexPath])
        let height = heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row]
        return (height != -1)
    }
    
    func cacheHeight(_ height: CGFloat, by indexPath:IndexPath) {
        automaticallyInvalidateEnabled = true
        buildCachesAtIndexPathsIfNeeded([indexPath])
        if UIDevice.current.orientation.isLandscape {
            heightsBySectionForLandscape[indexPath.section][indexPath.row] = height
        } else {
            heightsBySectionForPortrait[indexPath.section][indexPath.row] = height
        }
    }
    
    func heightFor(_ indexPath: IndexPath) -> CGFloat {
        buildCachesAtIndexPathsIfNeeded([indexPath])
        let height = heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row]
        return height
    }
    
    func invalidateHeight(at indexPath:IndexPath) {
        buildCachesAtIndexPathsIfNeeded([indexPath])
        heightsBySectionForLandscape[indexPath.section][indexPath.row] = -1
        heightsBySectionForPortrait[indexPath.section][indexPath.row] = -1
        
    }
    
    func invalidateAllHeightCache() {
        heightsBySectionForPortrait .removeAll()
        heightsBySectionForLandscape.removeAll()
    }
    
    
    
    func buildCachesAtIndexPathsIfNeeded(_ indexPaths: Array<IndexPath>) {
        indexPaths.forEach { (indexPath) in
            buildSectionsIfNeeded(indexPath.section)
            buildRowsIfNeed(row: indexPath.row ,inExist:indexPath.section)
        }
    }
    
    func buildSectionsIfNeeded(_ targetSection: Int ) {
        
        let sectionCount = heightsBySectionForLandscape.count
        for section in 0 ... targetSection {
            if section >= sectionCount {
                heightsBySectionForPortrait.append([CGFloat]())
                heightsBySectionForLandscape.append([CGFloat]())
            }
        }
    }
    
    func buildRowsIfNeed(row targetRow: Int ,inExist section:Int) {
        let rowCount = heightsBySectionForPortrait[section].count
        for r in 0 ... targetRow {
            if r >= rowCount {
                heightsBySectionForPortrait[section].append(-1)
                heightsBySectionForLandscape[section].append(-1)
                
            }

            
        }
    }
}


//MARK: - FDIndexPathHeightCacheInvalidation

// https://stackoverflow.com/questions/37886994/dispatch-once-in-swift-3
public extension DispatchQueue {
    private static var _onceTracker = [String]()
    
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}
extension UITableView {

    open override static func initialize() {
        struct Static {
            static var token = NSUUID().uuidString
        }

        if self != UIViewController.self {
            return
        }
        
        DispatchQueue.once(token: Static.token) {
            var selectors = [Selector]()
            selectors.append(#selector(UITableView.reloadData))
            selectors.append(#selector(UITableView.insertSections(_:with:)))
            selectors.append(#selector(UITableView.deleteSections(_:with:)))
            selectors.append(#selector(UITableView.reloadSections(_:with:)))
            selectors.append(#selector(UITableView.moveSection(_:toSection:)))
            selectors.append(#selector(UITableView.insertRows(at:with:)))
            selectors.append(#selector(UITableView.deleteRows(at:with:)))
            selectors.append(#selector(UITableView.reloadRows(at:with:)))
            selectors.append(#selector(UITableView.moveRow(at:to:)))
            
            
            var pc_selectors = [Selector]()
            pc_selectors.append(#selector(UITableView.pc_reloadData))
            pc_selectors.append(#selector(UITableView.pc_insertSections(_:with:)))
            pc_selectors.append(#selector(UITableView.pc_deleteSections(_:with:)))
            pc_selectors.append(#selector(UITableView.pc_reloadSections(_:with:)))
            pc_selectors.append(#selector(UITableView.pc_moveSection(_:toSection:)))
            pc_selectors.append(#selector(UITableView.pc_insertRows(at:with:)))
            pc_selectors.append(#selector(UITableView.pc_deleteRows(at:with:)))
            pc_selectors.append(#selector(UITableView.pc_reloadRows(at:with:)))
            pc_selectors.append(#selector(UITableView.pc_moveRow(at:to:)))
            

            for index in 0 ..< selectors.count {
                let originalMethod = class_getInstanceMethod(self, selectors[index])
                let swizzledMethod = class_getInstanceMethod(self, pc_selectors[index])
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
 
        }
        
        
    }
    
    func pc_reloadData() {
        if pc_indexPathHeightCache.automaticallyInvalidateEnabled {
           pc_indexPathHeightCache.heightsBySectionForPortrait.removeAll()
           pc_indexPathHeightCache.heightsBySectionForLandscape.removeAll()
        }
        self.pc_reloadData()
    }
    
    func pc_insertSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
        if pc_indexPathHeightCache.automaticallyInvalidateEnabled {
            sections.forEach{ (section) in
                pc_indexPathHeightCache.buildSectionsIfNeeded(section)
                pc_indexPathHeightCache.heightsBySectionForLandscape.insert([], at: section)
                pc_indexPathHeightCache.heightsBySectionForPortrait.insert([], at: section)
            }
        }
        self.pc_insertSections(sections, with: animation)
    }
    
    func pc_deleteSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
        if pc_indexPathHeightCache.automaticallyInvalidateEnabled {
            sections.forEach{ section in
                pc_indexPathHeightCache.buildSectionsIfNeeded(section)
                pc_indexPathHeightCache.heightsBySectionForPortrait.remove(at: section)
                pc_indexPathHeightCache.heightsBySectionForLandscape.remove(at: section)
            }
        }
       self.pc_deleteSections(sections, with: animation)
    }
    
    func pc_reloadSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
        if pc_indexPathHeightCache.automaticallyInvalidateEnabled {
            sections.forEach{ section in
                pc_indexPathHeightCache.buildSectionsIfNeeded(section)
                pc_indexPathHeightCache.heightsBySectionForPortrait[section].removeAll()
                pc_indexPathHeightCache.heightsBySectionForLandscape[section].removeAll()
            }
        }
        self.pc_reloadSections(sections, with: animation)
    }
    /// heheda
    func pc_moveSection(_ section: Int, toSection newSection: Int)
    {
        if pc_indexPathHeightCache.automaticallyInvalidateEnabled {
           pc_indexPathHeightCache.buildSectionsIfNeeded(section)
           pc_indexPathHeightCache.buildSectionsIfNeeded(newSection)
           var oldObj = pc_indexPathHeightCache.heightsBySectionForLandscape[section]
           var newObj = pc_indexPathHeightCache.heightsBySectionForLandscape[newSection]
           pc_indexPathHeightCache.heightsBySectionForLandscape[section] = newObj
           pc_indexPathHeightCache.heightsBySectionForLandscape[section] = oldObj
            
           oldObj = pc_indexPathHeightCache.heightsBySectionForPortrait[section]
           newObj = pc_indexPathHeightCache.heightsBySectionForPortrait[newSection]
           pc_indexPathHeightCache.heightsBySectionForPortrait[section] = newObj
           pc_indexPathHeightCache.heightsBySectionForPortrait[section] = oldObj
        }
        self.pc_moveSection(section, toSection: newSection)
    }
    
    func pc_insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation)
    {
        if pc_indexPathHeightCache.automaticallyInvalidateEnabled {
            pc_indexPathHeightCache.buildCachesAtIndexPathsIfNeeded(indexPaths)
            indexPaths.forEach{ indexPath in
            pc_indexPathHeightCache.heightsBySectionForPortrait[indexPath.section].insert(-1, at: indexPath.row)
            pc_indexPathHeightCache.heightsBySectionForLandscape[indexPath.section].insert(-1, at: indexPath.row)
            }
        }
        self.pc_insertRows(at: indexPaths, with: animation)
    }
    
    func pc_deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation)
    {
        if pc_indexPathHeightCache.automaticallyInvalidateEnabled {
            pc_indexPathHeightCache.buildCachesAtIndexPathsIfNeeded(indexPaths)
            var mutableIndexSetsToRemove: [Int: Set<Int>] = [:]
            indexPaths.forEach{ indexPath in
               var mutableIndexSet = mutableIndexSetsToRemove[indexPath.section]
                if mutableIndexSet == nil {
                    mutableIndexSet = Set()
                    mutableIndexSetsToRemove[indexPath.section] = mutableIndexSet
                }
//                mutableIndexSet.
//                mutableIndexSetsToRemove[indexPath.section].
                
            }
        }
        self.pc_deleteRows(at: indexPaths, with: animation)
    }
    
    func pc_reloadRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        if pc_indexPathHeightCache.automaticallyInvalidateEnabled  {
            pc_indexPathHeightCache.buildCachesAtIndexPathsIfNeeded(indexPaths)
            indexPaths.forEach{ indexPath in
                pc_indexPathHeightCache.heightsBySectionForLandscape[indexPath.section][indexPath.row] = -1
                
                pc_indexPathHeightCache.heightsBySectionForPortrait[indexPath.section][indexPath.row] = -1
                
            }
        }
        self.pc_reloadRows(at: indexPaths, with: animation)
    }
    
    func pc_moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        if(self.pc_indexPathHeightCache.automaticallyInvalidateEnabled) {
            pc_indexPathHeightCache.buildCachesAtIndexPathsIfNeeded([indexPath,newIndexPath])
            //
        }
        
        self.pc_moveRow(at: indexPath, to: newIndexPath)
    }

}


