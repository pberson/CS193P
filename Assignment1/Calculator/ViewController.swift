//
//  ViewController.swift
//  Calculator
//
//  Created by Peter Berson on 2/17/17.
//  Copyright © 2017 Peter Berson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak  var display: UILabel!
    
    @IBOutlet private weak var history: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let  digit = sender.currentTitle!
        
        // Prevent user from entering 0000 by never allowing any 0 if this is the first digit
        // and not setting userIsInTheMiddleOfTyping bool
        if (display.text == "0" && digit == "0") { return }

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

    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            if let num = Double(String(newValue)) {
                return display.text = brain.formatNumber(numAsDouble: num)
            } else {
                // We should never get here
                return display.text = String(newValue)
            }
        }
    }
    
    private var historyValue: String {
        get {
            return history.text!
        }
        set {
            return history.text = String(newValue)
        }
    }

    private var brain = CalculatorBrain()
    
    @IBAction func performClear() {
        brain.clear()
        displayValue = 0
        historyValue = " " // Set a space to mantian it from shrinking 
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        displayValue = brain.result
        
        // brain.description could be empty if user just press "="
        if !(brain.description.isEmpty) {
            historyValue = brain.isPartialResult ? brain.description + "..." : brain.description + " ="
        }
    }
}

