//
//  GraphViewController.swift
//  GraphingCalculator
//
//  Created by Peter Berson on 2/24/17.
//  Copyright © 2017 Peter Berson. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    @IBOutlet weak var graphView: GraphView!{
        didSet {
            graphView.datasource = self // connecting contoller to view
            
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(
                            target: graphView, action: #selector(GraphView.changeZoom(_:))
            ))
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(
                target: graphView, action: #selector(GraphView.moveGraph(_:))
            ))
            
            graphView.addGestureRecognizer(UITapGestureRecognizer(
                target: graphView, action: #selector(GraphView.tapChangeOrigin(_:))
            ))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("GrpahVC Loaded")
    }
    
    // This will take a CGFloat return the result of the function
    func getYcoordinate (x: CGFloat) -> CGFloat? {
        if let function = function {
            return CGFloat(function(x))
        } else {
            return nil
        }
    }
    
    // Typdef dunction whish is a public var to be used to accept a float and return double
    var function: ((CGFloat) -> Double)?
    
}
