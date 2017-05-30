//
//  ds.swift
//  SwiftTableViewHeightCache
//
//  Created by tangyuhua on 2017/5/28.
//  Copyright © 2017年 tangyuhua. All rights reserved.
//

import UIKit

// MARK: - PCTemplateLayoutCellDebug
private var debugLogEnabledKey: Void?

extension UITableView {
    var pc_debugLogEnable:Bool {
        get {
            return objc_getAssociatedObject(self, &debugLogEnabledKey) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &debugLogEnabledKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    func pc_debugLog(_ message: String ) {
        if pc_debugLogEnable {
            print("** PCTemplateLayoutCell ** \(message)")
        }
    }
}
