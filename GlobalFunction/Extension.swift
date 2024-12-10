//
//  Extension.swift
//  DLE
//
//  Created by meet sharma on 11/05/23.
//

import Foundation
import UIKit
import CoreLocation

extension UIButton{
    @IBInspectable var cornerRadi: CGFloat {
       get {
         return layer.cornerRadius
       }
       set {
         layer.cornerRadius = newValue
         layer.masksToBounds = newValue > 0
       }
     }
     @IBInspectable var borderWid: CGFloat {
       get {
         return layer.borderWidth
       }
       set {
         layer.borderWidth = newValue
       }
     }
     @IBInspectable var borderCol: UIColor? {
       get {
         return UIColor(cgColor: layer.borderColor!)
       }
       set {
         layer.borderColor = newValue?.cgColor
       }
     }
     
   }

extension UIView{
    @IBInspectable var borderWidth: CGFloat {
      get {
        return layer.borderWidth
      }
      set {
        layer.borderWidth = newValue
      }
    }
    @IBInspectable var borderColor: UIColor? {
      get {
        return UIColor(cgColor: layer.borderColor!)
      }
      set {
        layer.borderColor = newValue?.cgColor
      }
    }
    @IBInspectable var cornerRadis: CGFloat {
       get {
         return layer.cornerRadius
       }
       set {
         layer.cornerRadius = newValue
         layer.masksToBounds = newValue > 0
       }
     }
    @IBInspectable var scornerRadibotton: CGFloat {
        get {
          return layer.cornerRadius
        }
        set {
          layer.cornerRadius = newValue
          // layer.masksToBounds = newValue > 0
          layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
      }
      @IBInspectable var sTopBottomcornerRadibotton: CGFloat {
        get {
          return layer.cornerRadius
        }
        set {
          layer.cornerRadius = newValue
          layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        }
      }
      @IBInspectable var sbothTopcornerRadibotton: CGFloat {
        get {
          return layer.cornerRadius
        }
        set {
          layer.cornerRadius = newValue
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner]
        }
      }
      @IBInspectable var sbothbottomcornerRadibotton: CGFloat {
        get {
          return layer.cornerRadius
        }
        set {
          layer.cornerRadius = newValue
          layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
      }
      @IBInspectable var sbothleftCornerRadibotton: CGFloat {
        get {
          return layer.cornerRadius
        }
        set {
          layer.cornerRadius = newValue
          layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
      }
    
}


extension CLLocationDirection {
    var toRadians: Double { return Double(self) * .pi / 180 }
}

extension Double {

func toDegrees() -> Double {
  return self * 180.0 / .pi
}
}


extension UILabel {
    func applyGradientWith(startColor: UIColor, endColor: UIColor,colorValue:CGFloat) -> Bool {
        var startColorRed: CGFloat = 0
        var startColorGreen: CGFloat = 0
        var startColorBlue: CGFloat = 0
        var startAlpha: CGFloat = 0

        if !startColor.getRed(&startColorRed, green: &startColorGreen, blue: &startColorBlue, alpha: &startAlpha) {
            return false
        }

        var endColorRed: CGFloat = 0
        var endColorGreen: CGFloat = 0
        var endColorBlue: CGFloat = 0
        var endAlpha: CGFloat = 0

        if !endColor.getRed(&endColorRed, green: &endColorGreen, blue: &endColorBlue, alpha: &endAlpha) {
            return false
        }

        let gradientText = self.text ?? ""
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: self.font as Any]
        let textSize = gradientText.size(withAttributes: attributes)
        let width = textSize.width
        let height = textSize.height

        UIGraphicsBeginImageContext(CGSize(width: width, height: height))

        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return false
        }

        UIGraphicsPushContext(context)

        let glossGradient: CGGradient?
        let rgbColorspace: CGColorSpace?
        let num_locations: size_t = 2
        let locations: [CGFloat] = [colorValue, 1.0]
        let components: [CGFloat] = [startColorRed, startColorGreen, startColorBlue, startAlpha, endColorRed, endColorGreen, endColorBlue, endAlpha]
        rgbColorspace = CGColorSpaceCreateDeviceRGB()
        glossGradient = CGGradient(colorSpace: rgbColorspace!, colorComponents: components, locations: locations, count: num_locations)
        let topCenter = CGPoint.zero
        let bottomCenter = CGPoint(x: 0, y: textSize.height)
        context.drawLinearGradient(glossGradient!, start: topCenter, end: bottomCenter, options: CGGradientDrawingOptions.drawsBeforeStartLocation)

        UIGraphicsPopContext()

        guard let gradientImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return false
        }

        UIGraphicsEndImageContext()

        self.textColor = UIColor(patternImage: gradientImage)

        return true
    }
}
//MARK: - UICOLOR

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIView {
   func addGradient(_ colors: [UIColor], locations: [NSNumber], frame: CGRect = .zero) {

      // Create a new gradient layer
      let gradientLayer = CAGradientLayer()
      gradientLayer.colors = colors.map{ $0.cgColor }
      gradientLayer.locations = locations
      gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
       gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
      gradientLayer.frame = frame

      layer.insertSublayer(gradientLayer, at: 0)
   }
}
