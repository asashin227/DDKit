//
//  DDTextField.swift
//  DDKitDdemo
//
//  Created by Asakura Shinsuke on 2017/06/14.
//  Copyright © 2017年 Asakura Shinsuke. All rights reserved.
//

import UIKit

private protocol DDTextFieldTouchesEvent {
    func didLongPress(gesture: UILongPressGestureRecognizer)
}

public class DDTextField: UITextField, DDControlOperator {
    lazy private var gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DDTextField.didLongPress(gesture:)))
    public init() {
        super.init(frame: .zero)
        self.addGestureRecognizer(gesture)
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addGestureRecognizer(gesture)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DDTextField: UIGestureRecognizerDelegate {
    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let inputedText = self.text,
            let selectedRange = self.selectedTextRange else {
                return true
        }

        let startPos = offset(from: beginningOfDocument, to: selectedRange.start)
        let endPos = offset(from: beginningOfDocument, to: selectedRange.end)
        
        if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.classForCoder()) && !inputedText.isEmpty && startPos != endPos {
            if NSStringFromClass(gestureRecognizer.classForCoder) == "UILongPressGestureRecognizer" {
                return true
            }
             return false
        }
        
        return true
    }
}


extension DDTextField: DDTextFieldTouchesEvent {
    /// didLongPress EventListener
    ///
    /// - Parameter gesture: gesture obj
    @objc fileprivate func didLongPress(gesture: UILongPressGestureRecognizer) {
        guard let inputedText = self.text,
            let selectedRange = self.selectedTextRange else {
                return
        }
        
        let selectedRect = firstRect(for: selectedRange)
        
        // Hit decision
        guard selectedRect.contains(gesture.location(in: gesture.view)) else {
            return
        }
        
        
        // Get selected Text.
        let startPos = offset(from: beginningOfDocument, to: selectedRange.start)
        let endPos = offset(from: beginningOfDocument, to: selectedRange.end)
        let selectedText = (inputedText as NSString).substring(with: NSMakeRange(startPos, endPos - startPos)) as String
        
        self.selectedTextRange = nil
        
        // Add text and iamge for Drag&Drop control
        addControl(text: selectedText, touchedPoint: selectedRect.origin)
    }
}
