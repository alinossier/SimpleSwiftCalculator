//
//  ViewController.swift
//  SimpleSwiftCalculator
//
//  Created by Antonin Linossier on 5/28/17.
//  Copyright © 2017 Antonin Linossier. All rights reserved.
//

import UIKit
import Foundation


class ViewController: UIViewController, PushResultsDelegate {
    
    var InputTextField = UILabel() // Use a UILabel or UIButton or even a UITextField if you like
    weak var toolBar: SimpleSwiftCalculator!
    
    override func viewDidLoad() {
        
        let screenSize = UIScreen.main.bounds
        let ButtonWidth = screenSize.width / 4
        let ButtonHeight = ButtonWidth - ButtonWidth / 4
        let CurrentCalcLabelY = screenSize.height - (ButtonHeight * 5)

        // Insert the label that will show the results
        InputTextField.frame = CGRect(x: 0, y: CurrentCalcLabelY - 200, width: screenSize.width, height: ButtonHeight)
        InputTextField.textColor = UIColor.black
        InputTextField.font = InputTextField.font?.withSize(75)
        self.view.addSubview(InputTextField)
        
        
        let CalcInstance = SimpleSwiftCalculator(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        CalcInstance.becomeFirstResponder()
        CalcInstance.isUserInteractionEnabled = true
        CalcInstance.delegate = self
        self.view.addSubview(CalcInstance)

    }
    
    
    override func viewWillAppear(_ animated: Bool) {

    }
        
    func PushValueFromCalculator(value: String){
        InputTextField.text = value
    }
        
}
   
