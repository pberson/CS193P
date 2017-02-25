//
//  GraphView.swift
//  GraphingCalculator
//
//  Created by Peter Berson on 2/24/17.
//  Copyright © 2017 Peter Berson. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    
    @IBInspectable
    var color: UIColor = UIColor.black { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var scale: CGFloat = 1 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var graphOrigin: CGPoint! { didSet { setNeedsDisplay() } }

    var axes = AxesDrawer()
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        //let height = bounds.size.height
        //let width = bounds.size.width
       //let screenScale =  self.contentScaleFactor
        
        // Check to see if graphOrigin is set if not determine center of bounds
        graphOrigin = graphOrigin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        
        axes.drawAxes(inRect: self.bounds, origin: graphOrigin, pointsPerUnit: scale)
    }
    
    
    /******************* Gesture Handlers  Start ***********************/
    func changeZoom(_ recongnizer: UIPinchGestureRecognizer) {
        switch recongnizer.state {
        case .changed, .ended :
            scale *= recongnizer.scale
            recongnizer.scale = 1.0
        default:
            break
        }
    }
    
     func moveGraph(_ recongnizer: UIPanGestureRecognizer) {
        switch recongnizer.state {
        case .changed, .ended :
            let translation = recongnizer.translation(in: self)
            graphOrigin = CGPoint(x: graphOrigin.x + translation.x, y: graphOrigin.y + translation.y)
            recongnizer.setTranslation(CGPoint.zero, in: self)
        default:
            break
        }
    }

    /******************* Gesture Handlers End ***********************/

    

}
