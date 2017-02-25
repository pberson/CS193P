//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Peter Berson on 2/17/17.
//  Copyright © 2017 Peter Berson. All rights reserved.
//

import Foundation


class CalculatorBrain {
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    private var descriptionAccumulator = "" {
        didSet {
            if pending == nil {
                currrentPrecedence = Precedence.Max
            }
        }
    }

    // Track what is the current operation precedence * / higher then + -
    private enum Precedence: Int {
        case Min = 0
        case Max = 1
    }
    
    private var currrentPrecedence = Precedence.Max
    
    var variablesValues = [String: Double]() {
        didSet {
            // run program whenever a variable is set
            program = internalProgram as CalculatorBrain.PropertyList
        }
    }

    var isPartialResult = false
    
    var operationError: String?
    
    func setOperand(operand: Double) {
        // if we press an operand with no pending operator reset
        if pending == nil { clear () }
        accumulator =  operand
        internalProgram.append(operand as AnyObject)
        descriptionAccumulator = formatNumber(numAsDouble:operand)
    }
    
    func setOperand(variableName: String) {
        variablesValues[variableName] = variablesValues[variableName] ?? 0.0
        // Set the all accumulator's to either value or variable name
        accumulator = variablesValues[variableName]!
        internalProgram.append(variableName as AnyObject)
        descriptionAccumulator = variableName
    }
    
    func formatNumber(numAsDouble: Double) -> String {
        let num =  NumberFormatter()
        num.numberStyle = NumberFormatter.Style.decimal
        num.minimumFractionDigits = 0
        num.maximumFractionDigits = 6
        num.minimumIntegerDigits = 1
        num.usesGroupingSeparator = true
        return num.string(from: NSNumber(value:numAsDouble))!
    }
    
    var description: String {
        if pending == nil {
            return descriptionAccumulator
        } else {
            return pending!.descriptionFunction(pending!.firstDescriptionOperand, pending!.firstDescriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
        }
    }
    
    
    func clear () {
        pending = nil
        accumulator = 0.0
        isPartialResult = false
        descriptionAccumulator = ""
        internalProgram.removeAll()
    }
    
    func undo () {
        if !internalProgram.isEmpty {
            internalProgram.removeLast()
            program = internalProgram as CalculatorBrain.PropertyList
        }  else {
            clear()
        }
    }
 
    // TODO testing out new error checking.
    private func divide (x: Double, y: Double) -> (result: Double, error: String?) {
        return ( x != 0) ? (x/y,nil) : (x/y, "Error")
    }
    
    private func my_sqrt (x: Double) -> (result: Double, error: String?) {
        return  x >= 0 ? (sqrt(x),nil) : (sqrt(x), "Error")
    }
    
    // first closure is the operation second is the pretty string for description
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "rand" : Operation.NonOperandOperation(drand48, {"rand (\($0))"}),
        "±" : Operation.UnaryOperation({ (-$0,nil) }, {"-(\($0))"}),
        "√" : Operation.UnaryOperation( {$0 >= 0 ? (sqrt($0), nil) : (sqrt($0),"Math Error operand \($0) not valid!")} , {"√(\($0))"}),
        "cos" : Operation.UnaryOperation({(cos($0),nil)}, {"cos(\($0))"}),
        "sin" : Operation.UnaryOperation({(sin($0),nil)}, {"sin(\($0))"}),
        "tan" : Operation.UnaryOperation({(tan($0),nil)}, {"tan(\($0))"}),
        "x²" : Operation.UnaryOperation({(pow($0,2), nil)}, {"(\($0))²"}),
        "×" : Operation.BinaryOperation({ ($0 * $1, nil) }, { "\($0) × \($1)" }, Precedence.Max),
        "÷" : Operation.BinaryOperation({ $1 != 0 ? ($0 / $1, nil) : ($0 / $1, "Math Error Div Zero") }, { "\($0) ÷ \($1)" }, Precedence.Max),
        "-" : Operation.BinaryOperation({ ($0 - $1, nil) }, { "\($0) - \($1)" }, Precedence.Min),
        "+" : Operation.BinaryOperation({ ($0 + $1, nil) }, { "\($0) + \($1)" }, Precedence.Min),
        "=" : Operation.Equals,
        ]
    
    // Unary and Binary operations accept Doubles and (tuple) return Double and Error String 
    // The other function (except for Constant and Equals) have a secondary function that builds the descprtion string
    // These is taking advantage of Swift Function Closure capablities
    private enum Operation {
        case Constant(Double)
        case NonOperandOperation(() -> Double, (String) ->String)
        case UnaryOperation((Double) -> (result: Double, errorString: String?), (String) -> String)
        case BinaryOperation((Double, Double) -> (result: Double, errorString: String?), (String,String) -> String, Precedence)
        case Equals
    }
    
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                descriptionAccumulator = symbol
                accumulator = value
            case .NonOperandOperation(let function, let descriptionFunction):
                accumulator = function()
                descriptionAccumulator = descriptionFunction(String(formatNumber(numAsDouble: accumulator)))
            case .UnaryOperation(let function, let descriptionFunction):
                (accumulator,operationError) = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOperation(let function, let descriptionFunction, let precedence):
                executePendingBinaryOperation()
                if currrentPrecedence.rawValue < precedence.rawValue {
                    // wrap it in parans to show precenence
                    descriptionAccumulator = "(\(descriptionAccumulator))"
                }
                currrentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator,
                                                     descriptionFunction: descriptionFunction, firstDescriptionOperand: descriptionAccumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            (accumulator,operationError) = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.firstDescriptionOperand, descriptionAccumulator)
            pending = nil
            isPartialResult = false
        } else {
            isPartialResult = true
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> (Double, String?)
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var firstDescriptionOperand: String
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operation = op as? String {
                        // All we know is it's a string so it maybe a operation or variable need
                        // More checking
                        if operations.index(forKey: operation) != nil{
                            performOperation(symbol: operation)
                        } else {
                            setOperand(variableName: operation)
                        }
                    }
                }
            }
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}

