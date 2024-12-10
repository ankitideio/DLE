//
//  PopUpVC.swift
//  DLE
//
//  Created by meet sharma on 13/07/23.
//

import UIKit

class PopUpVC: UIViewController {
    
    //MARK: - OUTLETS
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var vwBackground: UIView!
    @IBOutlet weak var btnStart: UIButton!
    
    //MARK: - VARIABLES
    
    var isComing = ""
    var callBack:((_ type:String)->())?
    
    //MARK: - LIFE CYCLE METHOD
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uiSet()
    }
    
    //MARK: - FUNCTIONS
    
    func uiSet(){
        
//        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemUltraThinMaterialDark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = vwBackground.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        vwBackground.addSubview(blurEffectView)
        if isComing == "5"{
            print("5")
            lblTitle.text = "Start 5 minutes of Daily Light\n Exposure"
            btnStart.setTitle("Start", for: .normal)
        }else if isComing == "15"{
            print("15")
            lblTitle.text = "Start 15 minutes of Daily Light\n Exposure"
            btnStart.setTitle("Start", for: .normal)
        }else if isComing == "30"{
            print("30")
            lblTitle.text = "Start 30 minutes of Daily Light\n Exposure"
            btnStart.setTitle("Start", for: .normal)
        }else{
            print("0")
            lblTitle.text = "Are you sure you want to\n cancel?"
            btnStart.setTitle("Yes", for: .normal)
        }
        
    }
    
    //MARK: - ACTIONS
    
    @IBAction func actionCancel(_ sender: UIButton) {
        
        self.dismiss(animated: false)
    }
    
    @IBAction func actionStart(_ sender: UIButton) {
        
        self.dismiss(animated: false)
        callBack?(isComing)
    }
    func jumpAnimation() {
           let originalTransform = self.view.transform
           let scaleFactor: CGFloat = 1.2
        
           UIView.animate(withDuration: 0.2, animations: {
               self.view.transform = originalTransform.scaledBy(x: scaleFactor, y: scaleFactor)
           }) { _ in
               UIView.animate(withDuration: 0.2, animations: {
                   self.view.transform = originalTransform
               })
           }
       }

}
