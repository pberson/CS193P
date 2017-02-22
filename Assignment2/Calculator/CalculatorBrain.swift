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
    
    private var descriptionAccumulator = "" {
        didSet {
            if pending == nil {
                currrentPrecedence = Precedence.Max
            }
        }
    }
    
    var isPartialResult = false
    
    //private var internalProgram = [AnyObject]()
    
    // Track what is the current operation precedence * / higher then + -
    private enum Precedence: Int {
        case Min = 0
        case Max = 1
    }
    
    private var currrentPrecedence = Precedence.Max
    
    func setOperand(operand: Double) {
        if pending == nil { clear () }
        accumulator =  operand
        descriptionAccumulator = formatNumber(numAsDouble:operand)
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
    }
    
    // first closure is the operation second is the pretty string for description
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "rand" : Operation.NonOperandOperation(drand48, {"rand (\($0))"}),
        "±" : Operation.UnaryOperation({ -$0 }, {"-(\($0))"}),
        "√" : Operation.UnaryOperation(sqrt, {"√(\($0))"}),
        "cos" : Operation.UnaryOperation(cos, {"cos(\($0))"}),
        "sin" : Operation.UnaryOperation(sin, {"sin(\($0))"}),
        "tan" : Operation.UnaryOperation(tan, {"tan(\($0))"}),
        "x²" : Operation.UnaryOperation({pow($0,2)}, {"(\($0))²"}),
        "×" : Operation.BinaryOperation({ $0 * $1 }, { "\($0) × \($1)" }, Precedence.Max),
        "÷" : Operation.BinaryOperation({ $0 / $1 }, { "\($0) ÷ \($1)" }, Precedence.Max),
        "-" : Operation.BinaryOperation({ $0 - $1 }, { "\($0) - \($1)" }, Precedence.Min),
        "+" : Operation.BinaryOperation({ $0 + $1 }, { "\($0) + \($1)" }, Precedence.Min),
        "=" : Operation.Equals,
        ]
    
    private enum Operation {
        case Constant(Double)
        case NonOperandOperation(() -> Double, (String) ->String)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String,String) -> String, Precedence)
        case Equals
    }
    
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                descriptionAccumulator = symbol
                accumulator = value
            case .NonOperandOperation(let function, let descriptionFunction):
                accumulator = function()
                descriptionAccumulator = descriptionFunction(String(formatNumber(numAsDouble: accumulator)))
            case .UnaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOperation(let function, let descriptionFunction, let precedence):
                executePendingBinaryOperation()
                if currrentPrecedence.rawValue < precedence.rawValue {
                    // wrap it in parans to show precenence
                    descriptionAccumulator = "(\(descriptionAccumulator))"
                }
                currrentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator,
                                                     descriptionFunction: descriptionFunction, firstDescriptionOperand: descriptionAccumulator )
            case .Equals:
                executePendingBinaryOperation()
            }
            //print(operandsOperationsStack)
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.firstDescriptionOperand, descriptionAccumulator)
            pending = nil
            isPartialResult = false
        } else {
            isPartialResult = true
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var firstDescriptionOperand: String
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}

