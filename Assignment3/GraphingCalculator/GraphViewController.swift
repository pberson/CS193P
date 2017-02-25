//
//  GraphViewController.swift
//  GraphingCalculator
//
//  Created by Peter Berson on 2/24/17.
//  Copyright © 2017 Peter Berson. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func changeOrigin(_ sender: UITapGestureRecognizer) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var graphView: GraphView!{
        didSet {
            
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(
                            target: graphView, action: #selector(GraphView.changeZoom(_:))
            ))
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(
                target: graphView, action: #selector(GraphView.moveGraph(_:))
            ))
    
        }
    }

    private func updateUI() {
        // ToDo
    }
    
    // Handle Gestures for ViewController
    

    
    @IBAction func tapChangeOrigin(_ recongnizer: UITapGestureRecognizer) {
        if recongnizer.state == .ended {
            self.graphView.graphOrigin = recongnizer.location(in: recongnizer.view)
        }
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
