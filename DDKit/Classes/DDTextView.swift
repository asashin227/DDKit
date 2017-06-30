//
//  DDTextView.swift
//  DDKitDdemo
//
//  Created by Asakura Shinsuke on 2017/06/14.
//  Copyright © 2017年 Asakura Shinsuke. All rights reserved.
//

import UIKit

private protocol DDTextViewTouchesEvent {
    func didLongPress(gesture: UILongPressGestureRecognizer)
}

public class DDTextView: UITextView, DDControlOperator {
    lazy private var gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DDTextView.didLongPress(gesture:)))
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.addGestureRecognizer(gesture)
    }
    public convenience init(frame: CGRect) {
        self.init(frame: frame, textContainer: nil)
    }
   public  convenience init() {
        self.init(frame: .zero)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension DDTextView: UIGestureRecognizerDelegate {
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


extension DDTextView: DDTextViewTouchesEvent {
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
