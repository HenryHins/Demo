//
//  GlobalObject.swift
//  Demo
//
//  Created by Ngan Chi Hin on 21/6/2016.
//  Copyright © 2016 Oursky. All rights reserved.
//

import UIKit
import SKYKit

class GlobalObject: NSObject {
    
    struct GlobalVariables{
        static var currentUser: SKYUser?
        static var noteArray: [SKYRecord] = []
    }
    
}
