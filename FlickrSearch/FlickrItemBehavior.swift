//
//  FlickrItemBehavior.swift
//  FlickrSearch
//
//  Created by SeokWon Cheul on 2016. 1. 30..
//  Copyright © 2016년 Richard turton. All rights reserved.
//

import UIKit

class FlickrItemBehavior: UIDynamicItemBehavior {
    
    init(item: UIDynamicItem, attachedToAnchor:CGPoint)
    {
        super.init(items: [item])
        self.action = { () -> Void in
//            F = ma = - k * dx
            
        }
    }
    
}
