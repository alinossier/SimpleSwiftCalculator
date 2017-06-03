//
//  SimpleSwiftCalculator.swift
//  SimpleSwiftCalculator
//
//  Created by Antonin Linossier on 6/3/17.
//  Copyright © 2017 Antonin Linossier. All rights reserved.
//

import Foundation
import UIKit

protocol PushResultsDelegate {
    func PushValueFromCalculator(value: String)
}

class SimpleSwiftCalculator: UIView {
 
    // Delegate
    var delegate: PushResultsDelegate? = nil
    
    var ArrayOfSymbols = ["7", "8", "9", "÷", "4", "5", "6", "×", "1", "2", "3", "-", "0", ".", "c", "+"]
    
    // The string containing the operation to process
    var InputString = String()
    
    // Couple of rules that help me keep track of what's going on
    var IsCreatingDecimal = false
    var LastInputIsOperand = false
    var NumberHasBeenEntered = false
    
    // The labels displaying the current operation & the result
    let CurrentCalcLabel = UILabel()
    let ResultLabel = UILabel()
    
    // Vars caching the results to be displayed
    var Result = Double()
    var OperationInProgress = Double()
    
    //Struct that defines and describes each component of the operation stack
    
    struct Operand {
        var CoreOperand: OperationType
        var Value: Double
        
        init(CoreOperand: OperationType, Value: Double) {
            self.CoreOperand = CoreOperand
            self.Value = Value
        }
        
    }
    
    // Enum contening each operation currently supported
    enum OperationType {
        case multiply, add, substract, divide, numerical, popen, pclose
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.becomeFirstResponder()
        let screenSize = UIScreen.main.bounds
        let ButtonWidth = screenSize.width / 4
        let ButtonHeight = ButtonWidth - ButtonWidth / 4
        var CursorButtonX = CGFloat(0)
        var CursorButtonY =  screenSize.height - (ButtonHeight * 4)
        
        // Insert the 16 buttons the calculator needs
        for i in 0...15{
            let CalcButton = UIButton()
            if i == 4 || i == 8 || i == 12 {
                CursorButtonX = 0
                CursorButtonY = CursorButtonY + ButtonHeight
                // print(String(describing: CursorButtonX) + " : " + String(describing: CursorButtonY))
            } else if i != 0 {
                CursorButtonX = CursorButtonX + ButtonWidth
            }
            CalcButton.frame = CGRect(x: CursorButtonX , y: CursorButtonY, width: ButtonWidth, height: ButtonHeight)
            CalcButton.backgroundColor = UIColor.blue
            CalcButton.setTitle(ArrayOfSymbols[i], for: .normal)
            CalcButton.addTarget(self, action: #selector(self.ButtonPressed), for: .touchUpInside)
            CalcButton.addTarget(self, action: #selector(self.HoldDown), for: .touchDown)
            
            CalcButton.layer.borderWidth = 0.5;
            CalcButton.layer.borderColor = UIColor.white.cgColor
            self.addSubview(CalcButton)
        }
        
        
        // Insert the Label that will show the current calculations on top of the pad
        let CurrentCalcLabelY = screenSize.height - (ButtonHeight * 5)
        CurrentCalcLabel.frame = CGRect(x: 0, y: CurrentCalcLabelY, width: screenSize.width, height: ButtonHeight)
        CurrentCalcLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        CurrentCalcLabel.textColor = UIColor.white
        CurrentCalcLabel.font = ResultLabel.font.withSize(45)
        self.addSubview(CurrentCalcLabel)
        

        
    }
    
    // Get rid of those trailing 0s before sending the result
    func forTailingZero(temp: Double) -> String{
        let tempVar = String(format: "%g", temp)
        return tempVar
    }
    
    //Changes the color when button is pressed
    func HoldDown(sender:UIButton)
    {
        sender.backgroundColor = UIColor.white
    }
    
    
    
    // Handles button strokes
    func ButtonPressed(sender: UIButton){
        let OperatorPressed = sender.titleLabel?.text
        
        // Blue Color by default
        sender.backgroundColor = UIColor.blue
        
        switch OperatorPressed {
            
        case "1"?, "2"?, "3"?, "4"?, "5"?, "6"?, "7"?, "8"?, "9"?, "0"?:
            InputString.append(OperatorPressed!)
            LastInputIsOperand = false
            NumberHasBeenEntered = true
            
        case "."?:
            if !IsCreatingDecimal {InputString.append(OperatorPressed!)}
            IsCreatingDecimal = true
            
        case "c"?:
            delegate?.PushValueFromCalculator(value: "0")
            OperationInProgress = 0
            CurrentCalcLabel.text = ""
            InputString = ""
            IsCreatingDecimal = false
            NumberHasBeenEntered = false
            return
            
        case "÷"?, "×"?, "-"?, "+"?:
            IsCreatingDecimal = false
            if !LastInputIsOperand && NumberHasBeenEntered {InputString.append(OperatorPressed!)}
            LastInputIsOperand = true
            
            
        default:
            return
        }
        
        CurrentCalcLabel.text = InputString
        ProcessString()
    }
    
    
    
 
    
    
    //Execute the given operation and sends the result
    func Execute(FirstValue: Double, SecValue: Double, CoreOperand: OperationType)->Double{
        switch CoreOperand {
        case .multiply:
            print(String(FirstValue) + " x " + String(SecValue) + " = " + String(FirstValue * SecValue))
            return FirstValue * SecValue
        case .add:
            print(String(FirstValue) + " + " + String(SecValue) + " = " + String(FirstValue + SecValue))
            return FirstValue + SecValue
        case .substract:
            print(String(FirstValue) + " - " + String(SecValue) + " = " + String(FirstValue - SecValue))
            return FirstValue - SecValue
        case .divide:
            print(String(FirstValue) + " / " + String(SecValue) + " = " + String(FirstValue / SecValue))
            return FirstValue / SecValue
        default:
            return 0
        }
        
    }
    
    

    
    
    
    // Converts a given string into a "Stack" of operations, contening the numbers and each operand in order
    
    func ProcessString(){
        
        var OperationStack = [Operand?]()
        var OperationStackIndex = 0
        var CurrentNumber = ""
        
        
        // Loop through the string and build the OperationStack array
        for index in InputString.characters.indices {
            
            if InputString[index] == "÷" || InputString[index] == "+" || InputString[index] == "-" || InputString[index] == "×" {
                
                // Insert the number we've been building
                OperationStack.remove(at: OperationStackIndex)
                OperationStack.insert(Operand.init(CoreOperand: .numerical, Value: Double(CurrentNumber) ?? 0), at: OperationStackIndex)
                OperationStackIndex += 1
                CurrentNumber = ""
                
                // Add Operand to the operation Stack
                switch InputString[index] {
                case "÷":
                    OperationStack.insert(Operand.init(CoreOperand: .divide, Value: Double(CurrentNumber) ?? 0), at: OperationStackIndex)
                    OperationStackIndex += 1
                case "-":
                    OperationStack.insert(Operand.init(CoreOperand: .substract, Value: Double(CurrentNumber) ?? 0), at: OperationStackIndex)
                    OperationStackIndex += 1
                case "+":
                    OperationStack.insert(Operand.init(CoreOperand: .add, Value: Double(CurrentNumber) ?? 0), at: OperationStackIndex)
                    OperationStackIndex += 1
                case "×":
                    OperationStack.insert(Operand.init(CoreOperand: .multiply, Value: Double(CurrentNumber) ?? 0), at: OperationStackIndex)
                    OperationStackIndex += 1
                default:
                    return
                }
                
                
            } else {
                
                CurrentNumber = CurrentNumber + String(InputString[index])
                if OperationStack.count <= 1 && OperationStackIndex <= 1 && OperationInProgress == 0 {
                    Result = Double(CurrentNumber) ?? 0
                }
                
                if OperationStack.isEmpty {
                    OperationStack.insert(Operand.init(CoreOperand: .numerical, Value: Double(CurrentNumber) ?? 0), at: OperationStackIndex)
                } else {
                    
                    if OperationStack.indices.contains(OperationStackIndex) {
                        OperationStack[OperationStackIndex]?.Value = Double(CurrentNumber) ?? 0
                        OperationStack[OperationStackIndex]?.CoreOperand = .numerical
                        
                    } else {
                        
                        OperationStack.insert(Operand.init(CoreOperand: .numerical, Value: Double(CurrentNumber) ?? 0), at: OperationStackIndex)
                        
                    }
                    
                    
                }
                
            }
            
        }
        
        
        //        My Failed attempt at giving priority to multiplications and divisions (Executing them first)
        //        ReconstituteStackWithParenthesis(Stack: OperationStack as! [ViewController.Operand])
        
        
        // Now we execute the operations within the Stack but first we make sure that the values around the operand are not empty
        if OperationStack.indices.contains(OperationStackIndex - 2) && OperationStack.indices.contains(OperationStackIndex - 1) && OperationStack.indices.contains(OperationStackIndex){
            
            
            // Calculate the number of operations in the stack hence the number of times we will have to execute
            var NumberOfOperations = 0
            
            for i in 0...OperationStack.count {
                if OperationStack.indices.contains(i){
                    if OperationStack[i]?.CoreOperand != .numerical && OperationStack[i]?.CoreOperand != .popen && OperationStack[i]?.CoreOperand != .pclose  {
                        NumberOfOperations += 1
                    }
                }
            }
            
            
            for _ in 0...NumberOfOperations + 1 {
                
                let i = 1
                
                // Execute multiplication and divisions first - Scratch that, executing in order
                if OperationStack.indices.contains(i + 1){
                    if OperationStack[i]?.CoreOperand == .multiply || OperationStack[i]?.CoreOperand == .divide && OperationStack.indices.contains(i + 1) {
                        
                        OperationInProgress = Execute(FirstValue: (OperationStack[i - 1]?.Value)!, SecValue: (OperationStack[i + 1]?.Value)!, CoreOperand: (OperationStack[i]?.CoreOperand)!)
                        
                        // Remove the 3 components of the operation from the stack
                        OperationStack.removeSubrange(ClosedRange(uncheckedBounds: (lower: i - 1, upper: i + 1)))
                        
                        // Add the result of the operation
                        OperationStack.insert(Operand.init(CoreOperand: .numerical, Value: Double(OperationInProgress)), at: i - 1)
                        
                        
                    } else if OperationStack[i]?.CoreOperand != .numerical && OperationStack.indices.contains(i + 1) {
                        
                        // If the operation is substract then check to see if the number we substract from is negative - if so add
                        if OperationStack[i]?.CoreOperand == .substract && OperationStack.indices.contains(i - 2) && OperationStack[i - 2]?.CoreOperand == .substract{
                            
                            OperationInProgress = Execute(FirstValue: (OperationStack[i - 1]?.Value)!, SecValue: (OperationStack[i + 1]?.Value)!, CoreOperand: .add)
                        } else {
                            
                            OperationInProgress = Execute(FirstValue: (OperationStack[i - 1]?.Value)!, SecValue: (OperationStack[i + 1]?.Value)!, CoreOperand: (OperationStack[i]?.CoreOperand)!)
                            
                        }
                        
                        OperationStack.removeSubrange(ClosedRange(uncheckedBounds: (lower: i - 1, upper: i + 1)))
                        OperationStack.insert(Operand.init(CoreOperand: .numerical, Value: Double(OperationInProgress)), at: i - 1)
                        
                    }
                    
                } else {
                    
                    // End of Array
                    
                }
                
                if OperationInProgress != 0 { Result = OperationInProgress }
                
            }
            
        }
        
        delegate?.PushValueFromCalculator(value: forTailingZero(temp: Result))
        
    }
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////
    //                                                                       //
    // My Failed attempt at giving priority to multiplications and divisions //
    //                                                                       //
    ///////////////////////////////////////////////////////////////////////////
    
    func ReconstituteStackWithParenthesis(Stack: [Operand]){
        
        var OutputStringWithParenthesis = String()
        var OperationStackWithParenthesis = Stack
        var PInserted = false
        //        ["7", "8", "9", "÷", "4", "5", "6", "×", "1", "2", "3", "-", "0", ".", "c", "+"]
        
        for i in 0...Stack.count - 1{
            
            if Stack.indices.contains(i + 1){
                
                if Stack[i].CoreOperand == .multiply || Stack[i].CoreOperand == .divide && Stack.indices.contains(i + 1) {
                    
                    
                    // Check for Parenthesis backward first
                    for op in stride(from: i, to: 0, by: -2) {
                        
                        if Stack[op].CoreOperand == .add || Stack[op].CoreOperand == .substract {
                            // insert parenthesis at i + 2 but make sure it's the last one
                            OperationStackWithParenthesis.insert(Operand.init(CoreOperand: .pclose, Value: 0), at: op + 2)
                            PInserted = true
                            print("OP : " + String(op))
                            for x in stride(from: op, to: -2, by: -1) {
                                print("x : " + String(x))
                                if Stack.indices.contains(x) && (Stack[x].CoreOperand == .add || Stack[x].CoreOperand == .substract || Stack[x].CoreOperand == .numerical || Stack[x].CoreOperand == .pclose || Stack[x].CoreOperand == .popen) {
                                    
                                    // can be improved to avoid executing in else
                                    
                                } else {
                                    var firstpindex = Int()
                                    print("POPO")
                                    if x - 2 <= 0 {firstpindex = 0} else {firstpindex = x - 2}
                                    OperationStackWithParenthesis.insert(Operand.init(CoreOperand: .popen, Value: 0), at: firstpindex)
                                    
                                    
                                }
                                
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        
        if PInserted {
            
            for p in 0...OperationStackWithParenthesis.count - 1 {
                switch OperationStackWithParenthesis[p].CoreOperand {
                case .numerical:
                    OutputStringWithParenthesis.append(forTailingZero(temp: OperationStackWithParenthesis[p].Value))
                case .add:
                    OutputStringWithParenthesis.append("+")
                case .divide:
                    OutputStringWithParenthesis.append("÷")
                case .multiply:
                    OutputStringWithParenthesis.append("×")
                case .substract:
                    OutputStringWithParenthesis.append("-")
                case .pclose:
                    OutputStringWithParenthesis.append(")")
                case .popen:
                    OutputStringWithParenthesis.append("(")
                }
                
            }
            
            CurrentCalcLabel.text = OutputStringWithParenthesis
            print(OutputStringWithParenthesis)
        }
        
        
        
    }
  
}








