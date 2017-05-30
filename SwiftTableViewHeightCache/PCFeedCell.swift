//
//  PCFeedCell.swift
//  SwiftTableViewHeightCache
//
//  Created by tangyuhua on 2017/5/29.
//  Copyright © 2017年 tangyuhua. All rights reserved.
//

import UIKit

class PCFeedCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var contentImageView: UIImageView!

    
    // If you are not using auto layout,override this 
    // method end enable this by setting 
    // "pc_enforeFrameLayout" to true
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var totalHeight: CGFloat = 0
        totalHeight += self.titleLabel.sizeThatFits(size).height
        totalHeight += self.contentLabel.sizeThatFits(size).height
        totalHeight += self.contentImageView.sizeThatFits(size).height
        totalHeight += self.usernameLabel.sizeThatFits(size).height
        totalHeight += 40
        return CGSize(width: size.width, height: totalHeight)
    }

}
