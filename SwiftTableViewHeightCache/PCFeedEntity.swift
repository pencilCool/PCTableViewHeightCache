//
//  PCFeedEntity.swift
//  SwiftTableViewHeightCache
//
//  Created by tangyuhua on 2017/5/29.
//  Copyright © 2017年 tangyuhua. All rights reserved.
//

import Foundation

struct  PCFeedEntity {
    var identifier:String
    var title: String
    var content: String
    var username: String
    var time: String
    var imageName: String
    
    public init(dic dictionary: [String:String]) {
        identifier = PCFeedEntity.uniqueIdentifier();
        title = dictionary["title"]!;
        content = dictionary["content"]!;
        username = dictionary["username"]!;
        time = dictionary["time"]!;
        imageName = dictionary["imageName"]!;
    }
    
    static var counter: Int = 0
    
    static func uniqueIdentifier() -> String{
        counter += 1
        return "unique-id-\(counter)"
    }
    
}
