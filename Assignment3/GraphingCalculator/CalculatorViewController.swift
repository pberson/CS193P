//
//  ViewController.swift
//  Calculator
//
//  Created by Peter Berson on 2/17/17.
//  Copyright © 2017 Peter Berson. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet private weak  var display: UILabel!
    
    @IBOutlet private weak var history: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CalVC Loaded")
    }
    
    private var userIsInTheMiddleOfTyping = false
    
    private var variableIsSet = false
    
    private func updateUI() {
        displayValue = brain.result
        
        // brain.description could be empty if user just press "="
        if !(brain.description.isEmpty) {
            historyValue = brain.isPartialResult ? brain.description + "..." : brain.description + " ="
        } else {
            historyValue = " "
        }
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let  digit = sender.currentTitle!
        
        // Prevent user from entering 0000 by never allowing any 0 if this is the first digit
        // and not setting userIsInTheMiddleOfTyping bool
        if (display.text == "0" && digit == "0") {
            userIsInTheMiddleOfTyping = true
            return
        }

        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display!.text!
            if ( digit != "." || textCurrentlyInDisplay.range(of:".") == nil ) {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
            
            if digit == "." {
                display.text = "0" + display.text! // make . = 0.
            }
        }

        userIsInTheMiddleOfTyping = true
    }

    private var displayValue: Double? {
        get {
            return Double(display.text!)!
        }
        set {
            /*
            if let num = Double(String(newValue!)) {
                display.text = brain.formatNumber(numAsDouble: num)
            } */
            display.text = newValue != nil ? brain.formatNumber(numAsDouble: Double(newValue!)) : "0"
        }
    }
    
    private var historyValue: String? {
        get {
            return history.text!
        }
        set {
             history.text = newValue != nil ? newValue! : " "
        }
    }

    private var brain = CalculatorBrain()
    

    @IBAction func performAddVariable(_ sender: UIButton) {
        brain.setOperand(variableName: "M")
        variableIsSet = true
        updateUI()
    }
    
    
    @IBAction func performSetVariable() {
        brain.variablesValues["M"] = displayValue
        variableIsSet = true
        updateUI()
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func performUndo() {
        
        if userIsInTheMiddleOfTyping{
            let currentText = display.text!.characters
            if currentText.count != 1 {
                display.text! = String(currentText.dropLast())
            } else {
                // all numbers have now been deleted reset the display to initial state
                display.text! = "0"
                userIsInTheMiddleOfTyping = false
            }
        } else {
            brain.undo()
            updateUI()
        }
        
    }
    
    
    @IBAction func performClear() {
        if brain.variablesValues.index(forKey: "M") != nil {
            brain.variablesValues.removeValue(forKey: "M")
            variableIsSet = false
        }
        brain.clear()
        displayValue = nil
        historyValue = nil // Set a space to mantian it from shrinking
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        
        if brain.operationError != nil {
            //print("ErrorValue: \(brain.operationError)")
            let alert = UIAlertController(title: "Error", message: (brain.operationError! + " Yes to Undo "), preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Yes",
                                          style: .default,
                                          handler: { (alert: UIAlertAction!) in self.handlerMathAlertYes() } ) )
            alert.addAction(UIAlertAction(title: "No",
                                          style: .cancel,
                                          handler: { (alert: UIAlertAction!) in self.brain.operationError = nil } ) )
            present(alert, animated: true, completion: nil)
        }
        updateUI()
    }
    
    
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var destinationvc = segue.destination
        if let navcon = destinationvc as? UINavigationController {
            destinationvc = navcon.visibleViewController ?? destinationvc
        }
        if let graphvc = destinationvc as? GraphViewController {
            if segue.identifier == "showGraph" {
                if !brain.isPartialResult && variableIsSet {
                    // *************************
                    // Closure Function to compute all values for the graphViewController
                    graphvc.function = { (x: CGFloat ) -> Double in
                        self.brain.variablesValues["M"] = Double(x)
                        return self.brain.result
                        
                    }
                    // ********* Magic all happens above  *****
                }
            }
        }
    }
    
    
    private func handlerMathAlertYes (){
        // This will undo only the last step if it was binary opertion then it would remove the equals 
        // not equals and operand TODO would be to implement it better in Calculator Brain
        brain.undo()
        //brain.undo() // remove ( for binary this would clean it up better
        brain.operationError = nil
        updateUI()
    }
}

