//
//  DebugUtilities.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-19.
//

import UIKit

class DebugUtilities {
 
    static func printNavControllerAndRootVC(vc: UIViewController) {
        print("BEGIN=BEGIN=BEGIN=BEGIN=BEGIN=BEGIN=BEGIN=BEGIN")
        if let navController = vc.navigationController {
            print("NavController = \(navController.debugDescription)")
            print("Contains \(navController.viewControllers.count) view controllers")
            print("=== View Controllers ===")
            for vc in navController.viewControllers { print(vc.debugDescription) }
        } else {
            print("Couldn't get a reference to NavigationController")
        }
        print("+++++++++++++++++++++++++++++")
        print("+++++++++++++++++++++++++++++")
        if let rootVC = vc.view.window?.rootViewController {
            print("rootVC = \(rootVC.debugDescription)")
            print("rootVC has \(rootVC.children.count) children (push):")
            for vc in rootVC.children {
                print("Child: ", vc.debugDescription)
            }
            if rootVC.presentedViewController == nil {
                print("rootVC has no VC presented modally.")
            } else {
                print("rootVC has at least 1 VC presented modally.")
            }
            print("END=END=END=END=END=END=END=END=END")
        }
    }
    
    /** Function prints View Controllers heirarchy starting from Root View Controller
        Usage: in presenting View Controller call
        if let rootVC = self.view.window?.rootViewController { DebugUtilities.printFromRootVC(vc: rootVC, indent: 0) }   */
    static func printFromRootVC(vc: UIViewController, indent: Int) {
        if vc.children.count == 0 && vc.presentedViewController == nil {
            print("\(String(repeating: "   ", count: indent))\(vc.debugDescription)")
            return
        }
        if vc.children.count != 0 {
            print("\(String(repeating: "   ", count: indent))\(vc.debugDescription) has \(vc.children.count) children:")
            for vc in vc.children {
                printFromRootVC(vc: vc, indent: indent + 1)
            }
        }
        if vc.presentedViewController != nil {
            print("\(String(repeating: "   ", count: indent))\(vc.debugDescription) ->")
            printFromRootVC(vc: vc.presentedViewController!, indent: indent)
        }
    }
     
}
