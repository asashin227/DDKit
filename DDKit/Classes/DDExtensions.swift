//
//  DDExtension.swift
//  DDKitDdemo
//
//  Created by Asakura Shinsuke on 2017/06/14.
//  Copyright © 2017年 Asakura Shinsuke. All rights reserved.
//

import UIKit

struct DDExtension<ExBase> {
    let base: ExBase
    init (_ base: ExBase) {
        self.base = base
    }
}

protocol DDExtensionCompatible {
    associatedtype Compatible
    static var ddex: DDExtension<Compatible>.Type { get }
    var ddex: DDExtension<Compatible> { get }
}

extension DDExtensionCompatible {
    static var ddex: DDExtension<Self>.Type {
        return DDExtension<Self>.self
    }
    
    var ddex: DDExtension<Self> {
        return DDExtension(self)
    }
}


extension UIImage: DDExtensionCompatible {}
extension DDExtension where ExBase: UIImage {
    
}

extension UIView: DDExtensionCompatible {}
extension DDExtension where ExBase: UIView {
    
    /// Generate an image from view
    ///
    /// - Parameter rect: targetRect
    /// - Returns: captured image
    func capture(rect: CGRect = .zero) -> UIImage? {
        var targetRect: CGRect = base.bounds
        if rect != .zero {
            targetRect = rect
        }
        
        UIGraphicsBeginImageContextWithOptions(base.frame.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        base.layer.render(in: context)
        
        let capturedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        var opaque = false
        if let cgImage = capturedImage.cgImage {
            switch cgImage.alphaInfo {
            case .noneSkipLast, .noneSkipFirst:
                opaque = true
            default:
                break
            }
        }
        
        // crop
        UIGraphicsBeginImageContextWithOptions(targetRect.size, opaque, capturedImage.scale)
        capturedImage.draw(at: CGPoint(x: -targetRect.origin.x, y: -targetRect.origin.y))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func searchSubview(className: String) -> UIView? {
        var res: UIView?
        base.subviews.forEach() {
            subview in
            
            if subview.isKind(of: NSClassFromString(className)!) {
                res = subview
            }
        }
        return res
    }
}


extension DDExtension where ExBase: UITextField {
    
}

extension DDExtension where ExBase: UIWindow {

    func view(at point: CGPoint) -> UIView {
        let viewController = UIApplication.shared.ddex.currentViewController()
        
        if let navigationController = viewController.navigationController,
            point.y < navigationController.navigationBar.frame.size.height {
            if point.x < UIScreen.main.bounds.size.width / 4 {
                guard let barButton = navigationController.navigationBar.ddex.searchSubview(className: "UINavigationItemButtonView") else {
                    return navigationController.navigationBar
                }
                return barButton
            }

            guard let currentView = searchConflictView(in: navigationController.navigationBar, at: point) else {
                return navigationController.navigationBar
            }
            
            return currentView
        }

        guard let currentView = searchConflictView(in: viewController.view, at: point) else {
            return viewController.view
        }
        return currentView
    }
    
    func searchConflictView(in view: UIView, at point: CGPoint) -> UIView? {
        var sugest: UIView? = nil
        view.subviews.forEach() {
            subview in
            
            let viewRect = subview.convert(subview.bounds, to: base)
            if viewRect.contains(point) {
                sugest = subview
            }
            else if let item = searchConflictView(in: subview, at: point) {
                sugest = item
            }
        }
        if sugest != nil {
            while sugest != nil && (NSStringFromClass((sugest?.classForCoder)!).hasPrefix("_") || !(sugest?.canBecomeFirstResponder)!) {
                sugest = sugest?.superview
            }
        }
        return sugest
    }

}


extension UIApplication: DDExtensionCompatible {}
extension DDExtension where ExBase: UIApplication {
    
    /// 表示中のViewControllerを取得する
    ///
    /// - returns: UIViewController
    func currentViewController() -> UIViewController {
        var current: UIViewController
        var root = (base.windows.first?.rootViewController)! as UIViewController
        
        // モーダルビューが存在した場合はトップのものを取得
        while root.presentedViewController != nil {
            root = root.presentedViewController!
        }
        
        // rootがナビゲーションコントローラならば最後のViewControllerを取得
        if root.isKind(of: UINavigationController.classForCoder()) {
            current = (root as! UINavigationController).viewControllers.last!
        }
            // rootがタブバーコントローラならば選択中のViewControllerを取得
        else if root.isKind(of: UITabBarController.classForCoder()) {
            let selected = (root as! UITabBarController).selectedViewController
            
            // 選択中がナビゲーションコントローラならば最後のViewControllerを取得
            if (selected?.isKind(of: UINavigationController.classForCoder()))! {
                current = (selected as! UINavigationController).viewControllers.last!
            }
            else {
                current = selected!
            }
        }
        else {
            current = root
        }
        return current
    }
}
