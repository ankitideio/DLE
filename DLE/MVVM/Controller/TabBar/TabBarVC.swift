//
//  TabBarVC.swift
//  DLE
//
//  Created by meet sharma on 13/06/23.
//

import UIKit

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        addTopLine()
    }
    private func addTopLine() {
           let lineView = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 1))
        lineView.backgroundColor = UIColor(red: 81/255, green: 81/255, blue: 81/255, alpha: 0.5)
        
           tabBar.addSubview(lineView)
       }

   

}
