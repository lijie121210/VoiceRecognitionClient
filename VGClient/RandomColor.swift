//
//  RandomColor.swift
//  VGClient
//
//  Created by jie on 2017/3/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit
import FlatUIColors

extension UIColor {
    
    struct Flat {
        
        static let colors = [ FlatUIColors.lightSeaGreenColor(),
                              FlatUIColors.turquoiseColor(),
                              FlatUIColors.sunflowerColor(),
                              FlatUIColors.carrotColor(),
                              FlatUIColors.dodgerBlueColor(),
                              FlatUIColors.peterRiverColor(),
                              FlatUIColors.lightWisteriaColor(),
                              FlatUIColors.asbestosColor(),
                              FlatUIColors.alizarinColor(),
                              FlatUIColors.lynchColor()]
            .map { $0! }
    }
    
    static var randomFlatColor: UIColor {
        
        let to = Flat.colors.count
        
        let index = randomInteger(from: 0, to: to)
        
        return Flat.colors[index]
    }
}
