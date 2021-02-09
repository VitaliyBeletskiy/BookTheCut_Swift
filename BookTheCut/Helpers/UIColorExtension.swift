//
//  UIColorExtension.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-12-15.
//

import UIKit


extension UIColor {
    
    static public var ourYellow: UIColor {
        return UIColor(hex: "#FFDC00FF")!
    }
    
    static public var ourRed: UIColor {
        return UIColor(hex: "#EC3C1AFF")!
    }
    
    static public var iconGray: UIColor {
        return UIColor(hex: "#767676FF")!
    }
    
    /// converts a string literal with hex color value + alpha (f.e. "#6EA355FF") into UIColor
    public convenience init?(hex: String) {
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    let r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    let g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    let b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    let a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
    
}
