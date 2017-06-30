//
//  DDControl.swift
//  DDKitDdemo
//
//  Created by Asakura Shinsuke on 2017/06/14.
//  Copyright © 2017年 Asakura Shinsuke. All rights reserved.
//

import UIKit

public protocol DDControlOperator {
    
    func addControl(text: String, touchedPoint: CGPoint)
    func received(_ source: DDControlOperator, text: String)
}

extension DDControlOperator {
    /// Add text for Drag&Drop control
    ///
    /// - Parameters:
    ///   - text: selected text
    ///   - image: selected text image
    public func addControl(text: String, touchedPoint: CGPoint) {
        DDControl.shared.addOperation(source: self, text: text, point: touchedPoint)
    }
}

public extension DDControlOperator where Self: DDTextField {
    
    func received(_ source: DDControlOperator, text: String) {
        print(String(describing: self.classForCoder) + NSStringFromCGRect(self.frame))
        print("text: " + self.text! + " -> " + text)
        if self.text == nil {
            self.text = ""
        }
        self.text = self.text! + text
        print("text: " + self.text!)
    }
}

public extension DDControlOperator where Self: DDTextView {
    
    func received(_ source: DDControlOperator, text: String) {
        print(String(describing: self.classForCoder) + NSStringFromCGRect(self.frame))
        print("text: " + self.text! + " -> " + text)
        self.text = self.text + text
        print("text: " + self.text!)
    }
}

private protocol DDControlGestureEvent {
    func didMove(gesture: UIPanGestureRecognizer)
}

class DDControl: NSObject {
    static var shared: DDControl = {
        return DDControl()
    }()
    private override init() {
    }
    
    enum DDState {
        case none
        case inOperation
        case adaptation
    }
    
    enum DDViewType {
        case disable
        case enable
        case screenControl
    }
    
    private var operatingText: String?
    fileprivate var label: UILabel?
    
    private var source: DDControlOperator?
    private var target: DDControlOperator?
    
    var screenControlReactionTime: TimeInterval = 1
    fileprivate var timer: Timer?
    fileprivate var operatingControlitem: UIView?
    
    var state: DDState {
        if source == nil && target == nil {
            return .none
        }
        
        if source != nil && target == nil {
            return .inOperation
        }
        
        if source != nil && target != nil{
            return .adaptation
        }
        return .none
    }
    
    func addOperation(source: DDControlOperator, text: String, point: CGPoint) {
        guard let window = UIApplication.shared.delegate?.window.unsafelyUnwrapped else {
            return
        }
        if self.source != nil {
            return
        }
        
        self.source = source
        operatingText = text
        
        label = UILabel()
        label?.text = text
        label?.numberOfLines = 0
        label?.sizeToFit()
        label?.frame.size.width = (label?.frame.size.width)! + 20
        label?.frame.size.height = (label?.frame.size.height)! + 10
        label?.layer.cornerRadius = 5
        label?.clipsToBounds = true
        label?.textColor = .black
        label?.backgroundColor = .white
        label?.layer.borderColor = UIColor.lightGray.cgColor
        label?.layer.borderWidth = 0.5
        label?.textAlignment = .center
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(DDControl.didMove(gesture:)))
        
        window.addSubview(label!)
        label!.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.label?.alpha = 1
        })
        window.addGestureRecognizer(gesture)
        window.touchesBegan([UITouch.init()], with: UIEvent.init())
        label?.frame.origin = (source as! UIView).convert(point, to: window)
    }
    
    func endOperation(releasePoint: CGPoint) {
        
        guard let targetOperator = searchTargetOperator(point: releasePoint) else {
            source = nil
            operatingText = nil
            
            return
        }
        
        targetOperator.received(source!, text: operatingText!)
        source = nil
        operatingText = nil
    }
    
    func searchTargetOperator(point: CGPoint) -> DDControlOperator? {
        guard let window = UIApplication.shared.delegate?.window.unsafelyUnwrapped else {
            return nil
        }
        let view = window.ddex.view(at: point)
        
        if view is DDControlOperator {
            return view as? DDControlOperator
        }
        return nil
    }
    
    func screenControl(view: UIView) {
        switch view {
        case (let v) where v.isKind(of: NSClassFromString("UINavigationItemButtonView")!):
            let viewController = UIApplication.shared.ddex.currentViewController()
            
            guard let navigationController = viewController.navigationController else {
                return
            }
            navigationController.popViewController(animated: true)
        default:
            break
        }
    }
    
    func checkType(view: UIView) -> DDViewType {
        switch view {
        case is DDControlOperator:
            return .enable
        case (let v) where v.isKind(of: NSClassFromString("UINavigationItemButtonView")!):
            return .screenControl
            //        case (let v) where v.isKind(of: NSClassFromString("UINavigationItemButtonView")!):
        //            return .screenControl
        default:
            return .disable
        }
    }
    
    var touchingView: UIView?
    var befoColor: UIColor?
    
}

extension DDControl: DDControlGestureEvent {
    
    public func didMove(gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .ended:
            // drop
            guard let window = UIApplication.shared.delegate?.window.unsafelyUnwrapped else {
                return
            }
            window.removeGestureRecognizer(gesture)
            self.endOperation(releasePoint: (label?.center)!)
            UIView.animate(withDuration: 0.2, animations: {
                self.label?.alpha = 0
            }) {
                finished in
                if finished {
                    self.label?.removeFromSuperview()
                }
            }
            
            touchingView?.backgroundColor = befoColor
            touchingView = nil
            befoColor = nil
            print("Drop text\n\n")
            
        default:
            // move imageView
            let point = gesture.translation(in: gesture.view)
            
            let movedPoint = CGPoint(x: label!.center.x + point.x, y: label!.center.y + point.y)
            label?.center = movedPoint
            gesture.setTranslation(.zero, in: gesture.view)
            
            guard let window = UIApplication.shared.delegate?.window.unsafelyUnwrapped else {
                return
            }
            let view = window.ddex.view(at: movedPoint)
            
            
            let type = checkType(view: view)
            
            
            if type == .screenControl {
                if operatingControlitem == nil {
                    operatingControlitem = view
                    DispatchQueue.main.asyncAfter(deadline: .now() + screenControlReactionTime) {
                        if self.operatingControlitem == window.ddex.view(at: movedPoint) {
                            self.screenControl(view: view)
                            self.operatingControlitem = nil
                        }
                    }
                }
            } else {
                operatingControlitem = nil
            }
            
            if touchingView != view {
                touchingView?.backgroundColor = befoColor
                touchingView = view
                print(String(describing: touchingView?.classForCoder))
                print(type)
                befoColor = touchingView?.backgroundColor
                switch type {
                case .enable:
                    touchingView?.backgroundColor = .green
                case .screenControl:
                    touchingView?.backgroundColor = .blue
                case .disable:
                    touchingView?.backgroundColor = .red
                }
            }
        }
    }
    
}
