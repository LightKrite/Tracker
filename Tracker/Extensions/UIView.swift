//
//  UIView.swift
//  Tracker
//
//  Created by Egor Partenko on 09.07.2024.
//

import UIKit

extension UIView {
    func addGradientBorder(colors: [UIColor], width: CGFloat) {
            let gradient = CAGradientLayer()
            gradient.frame = bounds
            gradient.colors = colors.map { $0.cgColor }
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            
            let shape = CAShapeLayer()
            shape.lineWidth = width
            shape.path = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
            shape.strokeColor = UIColor.black.cgColor
            shape.fillColor = UIColor.clear.cgColor
            gradient.mask = shape
            
            layer.addSublayer(gradient)
        }
}
