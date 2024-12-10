//
//  CircleLable.swift
//  DLE
//
//  Created by meet sharma on 11/05/23.
//

import Foundation
import UIKit

@IBDesignable
class CircularLabel: UILabel {


    @IBInspectable var angle: CGFloat = 1.6
    @IBInspectable var clockwise: Bool = true

    override func draw(_ rect: CGRect) {
        centreArcPerpendicular()
    }
    /**
    This draws the self.text around an arc of radius r,
    with the text centred at polar angle theta
    */
    func centreArcPerpendicular() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let string = text ?? ""
        let size   = bounds.size
        context.translateBy(x: size.width / 2, y: size.height / 2)

        let radius = getRadiusForLabel()
        let l = string.count
        let attributes = [NSAttributedString.Key.font : self.font!]

        let characters: [String] = string.map { String($0) } // An array of single character strings, each character in str
        var arcs: [CGFloat] = [] // This will be the arcs subtended by each character
        var totalArc: CGFloat = 0 // ... and the total arc subtended by the string

        // Calculate the arc subtended by each letter and their total
        for i in 0 ..< l {
            arcs += [chordToArc(characters[i].size(withAttributes: attributes).width, radius: radius)]
            totalArc += arcs[i]
        }

        let direction: CGFloat = clockwise ? -1 : 1
        let slantCorrection = clockwise ? -CGFloat.pi/2 : CGFloat.pi/2

        var thetaI = angle - direction * totalArc / 2

        for i in 0 ..< l {
            thetaI += direction * arcs[i] / 2
            centre(text: characters[i], context: context, radius: radius, angle: thetaI, slantAngle: thetaI + slantCorrection)
    
            thetaI += direction * arcs[i] / 2
        }
    }

    func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat {
       
        return 2 * asin(chord / (2 * radius))
    }

    /**
    This draws the String str centred at the position
    specified by the polar coordinates (r, theta)
    i.e. the x= r * cos(theta) y= r * sin(theta)
    and rotated by the angle slantAngle
    */
    func centre(text str: String, context: CGContext, radius r:CGFloat, angle theta: CGFloat, slantAngle: CGFloat) {
        // Set the text attributes
        let attributes : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: textColor!,
            NSAttributedString.Key.font: font!
            ]
        // Save the context
        context.saveGState()
        // Move the origin to the centre of the text (negating the y-axis manually)
        context.translateBy(x: r * cos(theta), y: -(r * sin(theta)))
        // Rotate the coordinate system
        context.rotate(by: -slantAngle)
        // Calculate the width of the text
        let offset = str.size(withAttributes: attributes)
        // Move the origin by half the size of the text
        context.translateBy(x: -offset.width / 2, y: -offset.height / 2) // Move the origin to the centre of the text (negating the y-axis manually)
        // Draw the text
        str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        // Restore the context
        context.restoreGState()
    }

    func getRadiusForLabel() -> CGFloat {
      
        let smallestWidthOrHeight = min(bounds.size.height, bounds.size.width)
        let heightOfFont = text?.size(withAttributes: [NSAttributedString.Key.font: self.font!]).height ?? 0

        // Dividing the smallestWidthOrHeight by 2 gives us the radius for the circle.
        return (smallestWidthOrHeight/2) - heightOfFont + 5
    }
}
