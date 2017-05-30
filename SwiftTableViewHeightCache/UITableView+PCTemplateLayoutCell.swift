//
//  UITableView+YHCacheHeight.swift
//  SwiftTableViewHeightCache
//

//  Created by tangyuhua on 2017/5/28.
//  Copyright © 2017年 tangyuhua. All rights reserved.
//

import UIKit

import ObjectiveC



typealias ConfigureBlock = (_ cell : UITableViewCell) -> ()
private var dicAssociationKey: Void?
private var systemFittingHeightKey: Void?

extension UITableViewCellAccessoryType {
    var widthOfView: CGFloat {
        get {
            switch self {
            case .none:                    return 0.0
            case .disclosureIndicator:     return 34.0
            case .detailDisclosureButton:  return 68.0
            case .checkmark:               return 40.0
            case .detailButton:            return 48.0
            }
        }
    }
}

// MARK: - Cache by Template
extension UITableView {
    

    
    var templateCellsByIdentifiers: [String: UITableViewCell] {
        get {
            return objc_getAssociatedObject(self, &dicAssociationKey) as? [String: UITableViewCell] ?? [:]
        }
        set(newValue) {
            objc_setAssociatedObject(self, &dicAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func pc_systemFittingHeightFor(_ cell: UITableViewCell) -> CGFloat {
        var  contentViewWidth = self.frame.size.width
        if let accessoryView = cell.accessoryView {
            contentViewWidth -= 16 + accessoryView.frame.size.width
        } else {
            contentViewWidth -= cell.accessoryType.widthOfView
        }
        
        var fittingHeight: CGFloat = 0
        if cell.pc_enforeFrameLayout && contentViewWidth > 0 {
            let widthFenceConstraint = NSLayoutConstraint(item: cell.contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: contentViewWidth)
            cell.contentView.addConstraint(widthFenceConstraint)
            fittingHeight = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            cell.contentView.removeConstraint(widthFenceConstraint)
            print("calculate using system fitting size (AutoLayout) - \(fittingHeight)")
        }
        
        if fittingHeight == 0 {
            #if DEBUG
                if  cell.contentView.constraints.count > 0{
                    if let _ = objc_getAssociatedObject(self, &systemFittingHeightKey) {
                         print("[FDTemplateLayoutCell] Warning once only: Cannot get a proper cell height (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in cell, making it into 'self-sizing' cell.");
                        objc_setAssociatedObject(self, &systemFittingHeightKey, true, .OBJC_ASSOCIATION_ASSIGN)
                    }
                }
                
            #endif
            
            fittingHeight = cell.sizeThatFits(CGSize(width: contentViewWidth, height: 0)).height
            
            pc_debugLog("calculate using sizeThatFits - \(fittingHeight)")
        }
        
        if fittingHeight == 0 {
            fittingHeight = 44
        }
        
        if self.separatorStyle != .none {
            fittingHeight += 1.0 / UIScreen.main.scale
        }
        
        return fittingHeight

    }
    
    func pc_heightForCell(withIdentifier identifier: String, configure: ConfigureBlock) -> CGFloat {
        let templateLayoutCell = pc_templateCellFor(reuseIdentifier: identifier)
        templateLayoutCell.prepareForReuse()
        configure(templateLayoutCell)
        return pc_systemFittingHeightFor(templateLayoutCell)
    }
    
    
    
    func pc_templateCellFor(reuseIdentifier identifier: String) -> UITableViewCell
    {
        let templateCell = templateCellsByIdentifiers[identifier] ?? dequeueReusableCell(withIdentifier :identifier)!
        return templateCell
    }

}


//MARK:
private var isTemplateLayoutCellKey: Void?
private var enforceFrameLayoutKey: Void?

extension UITableViewCell {
    
    var pc_isTemplateLayoutCell: Bool {
        get {
            return objc_getAssociatedObject(self, &isTemplateLayoutCellKey) as? Bool ?? false

        }
        
        set (newValue) {
            objc_setAssociatedObject(self, &isTemplateLayoutCellKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        
    }
    
    var pc_enforeFrameLayout: Bool {
        get {
            return objc_getAssociatedObject(self, &enforceFrameLayoutKey) as? Bool ?? false
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &enforceFrameLayoutKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

}


