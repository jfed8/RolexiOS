//
//  PFGroup.swift
//  Locktime
//
//  Created by J J Feddock on 1/24/19.
//  Copyright © 2019 HF Corporation. All rights reserved.
//

import UIKit
import Parse

class LTGroup: PFObject, PFSubclassing {
    @NSManaged var GroupID: String
    @NSManaged var GroupName: String
    @NSManaged var pointTime: Int
    
    class func parseClassName() -> String! {
        return "LTGroup"
    }
}
