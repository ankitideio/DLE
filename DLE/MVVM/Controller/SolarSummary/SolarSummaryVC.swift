//
//  SolarSummaryVC.swift
//  DLE
//
//  Created by meet sharma on 12/07/23.
//

import UIKit

class SolarSummaryVC: UIViewController {
    
    //MARK: - OUTLETS
    
    @IBOutlet weak var heightTblVw: NSLayoutConstraint!
    @IBOutlet weak var tblVwSummary: UITableView!
    @IBOutlet weak var lblMinutes: UILabel!
    @IBOutlet weak var lblTotalTime: UILabel!
    
    //MARK: - VARIABLES
    
    var arrSummary = [SummaryList]()
    var totolMin = 0
    
    //MARK: - LIFE CYCLE METHOD
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.heightTblVw.constant = CGFloat(((Store.solarSummary?.count ?? 0)*94))
        uiSet()
    }
    
    //MARK: - FUNCTIONS
    
    func uiSet(){
        
        totolMin = 0
        print(Store.solarSummary ?? "")
        Store.solarSummary = Store.solarSummary?.filter { i in
            return (i["time"] as? String) != nil && (i["time"] as? String) != ""
        }
      
        setGradiantColor(lable: lblTotalTime,value: 0.4)
        setGradiantColor(lable: lblMinutes, value: 0.2)
        for i in Store.solarSummary ?? []{
            totolMin += Int(i["time"] as? String ?? "") ?? 0
            arrSummary.append(SummaryList(date: i["date"] as? String ?? "",time: i["time"] as? String ?? ""))
        }
        lblTotalTime.text = "\(totolMin)"
        print(arrSummary)
        arrSummary.reverse()
        tblVwSummary.reloadData()
    }
    
    func setGradiantColor(lable:UILabel,value:CGFloat){
        if lable.applyGradientWith(startColor: UIColor(red: 255/255, green: 230/255, blue: 0/255, alpha: 1.0), endColor: UIColor(red: 239/255, green: 37/255, blue: 9/255, alpha: 1.0), colorValue: value) {
        }
        else {
            lable.textColor = .orange
        }
        
        
    }
}

//MARK: - TABLEVIEW DELEGATE AND DATA SOURCE

extension SolarSummaryVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSummary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SolarSummaryTVC", for: indexPath) as! SolarSummaryTVC
        self.setGradiantColor(lable: cell.lblTime, value: 0.2)
        cell.lblDate.text = arrSummary[indexPath.row].date ?? ""
        cell.lblTime.text = "\(arrSummary[indexPath.row].time ?? "") Minutes"
        if arrSummary[indexPath.row].time ?? "" == "5"{
            cell.imgVwSun.image = UIImage(named: "☀️")
        }else if arrSummary[indexPath.row].time ?? "" == "15"{
            cell.imgVwSun.image = UIImage(named: "⛅️")
        }else{
            cell.imgVwSun.image = UIImage(named: "☁️")
        }
       
        return cell
        
    }
    
    
}
