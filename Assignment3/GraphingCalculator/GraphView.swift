//
//  GraphView.swift
//  GraphingCalculator
//
//  Created by Peter Berson on 2/24/17.
//  Copyright © 2017 Peter Berson. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {
    func getYcoordinate(x: CGFloat ) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {
    
    
    @IBInspectable
    var color: UIColor = UIColor.black { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var scale: CGFloat = 10 { didSet { setNeedsDisplay() } } // This sets points per unit meanin do if 10 then .10 .20 ... 1
    
    @IBInspectable
    var graphOrigin: CGPoint! { didSet { setNeedsDisplay() } }
    
    private var axes = AxesDrawer()
    
    var datasource: GraphViewDataSource?

    
    override func draw(_ rect: CGRect) {
        
        //let screenScale =  self.contentScaleFactor
    
        // Check to see if graphOrigin is set if not determine center of bounds
        graphOrigin = graphOrigin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        axes.drawAxes(inRect: bounds, origin: graphOrigin, pointsPerUnit: scale)
        pathForFunction()?.stroke()
    }
    
    func pathForFunction () -> UIBezierPath? {
        
        let linePath = UIBezierPath()
        let width = Int(bounds.size.width * scale) // of CGRect of x axis within bounds scaled
        var point = CGPoint()
        var pathStarted = false
        
        if let data = datasource {
            for pixel in 0...width {
                point.x  = CGFloat(pixel) / scale
                
                // Not wthat we have an x calue get the y value by calling the protocol
                // function which will call the "Cal Brain" sorta from the CalculatorViewController
                // Using Protocol and Closure function
                
                if let y = data.getYcoordinate(x: (point.x - graphOrigin.x) / scale) {
                    if y.isNormal || y.isZero {
                        // Adjust for the cooridate system remmebmer 0,0 is the upper left
                        point.y = graphOrigin.y - y * scale
                        // print("Y Value \(y)")
                        // Path has not been strated so use move to
                        if !pathStarted {
                            linePath.move(to:point)
                            pathStarted = true
                            // Path is started so just add a point
                        } else {
                            linePath.addLine(to:point)
                        }
                    }
                    
                }
                
            }
            return linePath
        } else {return nil}
        
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
    
    func tapChangeOrigin(_ recongnizer: UITapGestureRecognizer) {
        if recongnizer.state == .ended {
            graphOrigin = recongnizer.location(in: recongnizer.view)
        }
    }
    
    
    /******************* Gesture Handlers End ***********************/
    
    

}
