//
//  GraphView.swift
//  GraphingCalculator
//
//  Created by Peter Berson on 2/24/17.
//  Copyright © 2017 Peter Berson. All rights reserved.
//

import UIKit


class GraphView: UIView {

    
    var graphCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    var axes = AxesDrawer()
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        //let height = bounds.size.height
        //let width = bounds.size.width
       let screenScale =  self.contentScaleFactor
        axes.drawAxes(inRect: self.bounds, origin: graphCenter, pointsPerUnit: screenScale)
    }
    

}
