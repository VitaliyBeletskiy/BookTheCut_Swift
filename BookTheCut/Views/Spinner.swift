//
//  Spinner.swift
//  BookTheCut
//
//  Created by Vitaliy on 2020-10-20.
//

import UIKit
 
public class Spinner {
 
    internal static var spinner: UIActivityIndicatorView?
 
    public static var style: UIActivityIndicatorView.Style = .large
 
    public static var baseBackColor = UIColor(white: 0, alpha: 0.7)
 
    public static var baseColor = UIColor.white
 
    public static func start(_ sender: UIViewController, style: UIActivityIndicatorView.Style = style, backColor: UIColor = baseBackColor, baseColor: UIColor = baseColor) {
        if spinner == nil {
            let window = sender.view.window!
            let frame = UIScreen.main.bounds
            spinner = UIActivityIndicatorView(frame: frame)
            spinner!.backgroundColor = backColor
            spinner!.style = style
            spinner?.color = .white
            window.addSubview(spinner!)
            spinner!.startAnimating()
        }
    }
      
    public static func stop() {
        if spinner != nil {
            spinner!.stopAnimating()
            spinner!.removeFromSuperview()
            spinner = nil
        }
    }
}
