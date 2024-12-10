//
//  CompassVC.swift
//  DLE
//
//  Created by meet sharma on 11/05/23.
//

import UIKit
import CoreLocation
import SunKit
import CoreMotion
import Solar
import AudioToolbox

class CompassVC: UIViewController {
    
     //MARK: - OUTLETS
    
    @IBOutlet weak var linearProgressVw: LinearProgressView!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var btnCloudCover: UIButton!
    @IBOutlet weak var btnSunny: UIButton!
    @IBOutlet weak var btnPartyCloud: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var stackVw: UIStackView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblSolarAngle: UILabel!
    @IBOutlet weak var lblAngle: UILabel!
    @IBOutlet weak var imgVwMoon: UIImageView!
    @IBOutlet weak var imgVwCompass: UIImageView!
    @IBOutlet weak var sunImgCenterX: NSLayoutConstraint!
    @IBOutlet weak var sunImgCenterY: NSLayoutConstraint!
    @IBOutlet weak var imgVwArrow: UIImageView!
    @IBOutlet weak var imgVwRotateCompass: UIImageView!
    @IBOutlet weak var imgVwSun: UIImageView!
    @IBOutlet weak var lblProgressStatus: UILabel!
    
    //MARK: - VARIABLES
    
    let locationManager = CLLocationManager()
    var sunDirectionIndex = 0
    var sunDirection = ""
    var sunAngle = 0
    var seconds: Int = 0
    var isTimerRunning: Bool = false
    var directions = [
        "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
        "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"
    ]
    var maxSunRadius = 0
    var minSunRadius = 0
    var selfDirection = ""
    var compassAngle = 0
    var lat = Double()
    var long = Double()
    var sunRise = Double()
    var sunSet = Double()
    var nowTime = Double()
    let motionManager = CMMotionManager()
    var timer : Timer?
    var timerBackground : Timer?
    var todayDate = ""
    var arrSummary = [SummaryList]()
    var currentProgress: Float = 1.0
    var callBack:(()->())?
    
    //MARK: - LIFE CYCLE METHOD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       uiSet()
       

        
    }
   
 
    override func viewWillAppear(_ animated: Bool) {
 
        lblTimer.text = "\(timeFormatted(Store.counter))"
        linearProgressVw.setProgress(Float(Store.counter), animated: true)
        if Store.startTimer == true{
            startTimer()
        }
    }
   

    //MARK: - FUNCTIONS
    func uiSet(){
       
        if  UserDefaults.standard.bool(forKey: "fetchLatLong") == true {
            imgVwSun.isHidden = false
        }else{
            imgVwSun.isHidden = true
        }
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.startUpdatingHeading()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        setTimerData()
        getTodayDate()
        
    }
  
  
    func startTimer(){
        
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
    }
    
    func stopTimerTest() {
      timer?.invalidate()
      timer = nil
        
    }
    
    func setTimerData(){
       
        if Store.startMinute == "5"{
            btnPause.isHidden = false
            btnSave.isHidden = false
            btnCross.isHidden = false
            linearProgressVw.maximumValue = 300
            self.btnSunny.isUserInteractionEnabled = false
            self.btnPartyCloud.isUserInteractionEnabled = false
            self.btnCloudCover.isUserInteractionEnabled = false
            self.btnSunny.setImage(UIImage(named: ""), for: .normal)
            self.btnPartyCloud.setImage(UIImage(named: "Text Button 1"), for: .normal)
            self.btnCloudCover.setImage(UIImage(named: "Text Button 2"), for: .normal)
            self.btnSunny.setTitle("☀️ Sunny (5 minutes)", for: .normal)
            self.btnPartyCloud.setTitle("", for: .normal)
            self.btnCloudCover.setTitle("", for: .normal)
            self.btnCross.setImage(UIImage(named: "TextBox"), for: .normal)
            self.btnSave.setImage(UIImage(named: ""), for: .normal)
            self.btnSave.setTitle("Save", for: .normal)
         
            self.btnSunny.backgroundColor = UIColor(hexString: "#FFC805")
            self.btnSunny.setTitleColor(UIColor(hexString: "#000000"), for: .normal)
            self.btnPartyCloud.backgroundColor = UIColor(hexString: "#007AFF")
            self.btnPartyCloud.setTitleColor(UIColor(hexString: "#FBFCFC"), for: .normal)
            self.btnCloudCover.backgroundColor = UIColor(hexString: "#007AFF")
            self.btnCloudCover.setTitleColor(UIColor(hexString: "#FBFCFC"), for: .normal)
            self.btnCross.backgroundColor = UIColor(red: 186/255, green: 11/255, blue: 11/255, alpha: 0.3)
           
//            self.btnSave.backgroundColor = UIColor(hexString: "#9BA5B9")
            if Store.isPause == true{
                self.lblProgressStatus.text = "(paused)"
                self.lblProgressStatus.textColor = UIColor(hexString: "#FFE600")
                btnPause.setTitle("Resume", for: .normal)
                btnPause.borderCol = UIColor(hexString: "#FFFFFF")
                btnPause.borderWid = 1
                self.btnCross.isUserInteractionEnabled = true
                self.btnPause.isUserInteractionEnabled = true
                self.btnSave.isUserInteractionEnabled = false
                self.btnPause.setImage(UIImage(named: ""), for: .normal)
                self.btnPause.backgroundColor = UIColor(red: 81/255, green: 175/255, blue: 96/255, alpha: 0.3)
            }else{
                
                if Store.counter >= 300{
                    self.btnSave.backgroundColor = UIColor(hexString: "#67CE67")
                    self.lblProgressStatus.text = "(Complete)"
                    self.lblProgressStatus.textColor = UIColor(hexString: "#52FFA2")
                    self.btnCross.isUserInteractionEnabled = true
                    self.btnPause.isUserInteractionEnabled = false
                    self.btnSave.isUserInteractionEnabled = true
                    self.btnPause.setImage(UIImage(named: "Text Button 4"), for: .normal)
                    self.btnPause.setTitle("", for: .normal)
                    self.btnPause.borderCol = .clear
                    self.btnPause.borderWid = 0
                    self.btnPause.backgroundColor = UIColor(hexString: "#9BA5B9")
                }else{
                    self.btnSave.backgroundColor = UIColor(hexString: "#9BA5B9")
                    self.lblProgressStatus.text = "(tracking)"
                    self.lblProgressStatus.textColor = UIColor(hexString: "#52FFA2")
                    self.btnCross.isUserInteractionEnabled = true
                    self.btnPause.isUserInteractionEnabled = true
                    self.btnSave.isUserInteractionEnabled = false
                    self.btnPause.setImage(UIImage(named: ""), for: .normal)
                    self.btnPause.setTitle("Pause", for: .normal)
                    self.btnPause.borderCol = UIColor(hexString: "#FFFFFF")
                    self.btnPause.borderWid = 1
                    self.btnPause.backgroundColor = UIColor(red: 81/255, green: 175/255, blue: 96/255, alpha: 0.3)
                }
                }
        }else if Store.startMinute == "15"{
            btnPause.isHidden = false
            btnSave.isHidden = false
            btnCross.isHidden = false
            linearProgressVw.maximumValue = 900
            self.btnSunny.isUserInteractionEnabled = false
            self.btnPartyCloud.isUserInteractionEnabled = false
            self.btnCloudCover.isUserInteractionEnabled = false
            self.btnSunny.setImage(UIImage(named: "Text Button"), for: .normal)
            self.btnPartyCloud.setImage(UIImage(named: ""), for: .normal)
            self.btnCloudCover.setImage(UIImage(named: "Text Button 2"), for: .normal)
            self.btnSunny.setTitle("", for: .normal)
            self.btnPartyCloud.setTitle("⛅ Partly Cloudy (15 minutes)", for: .normal)
            self.btnCloudCover.setTitle("", for: .normal)
            self.btnCross.setImage(UIImage(named: "TextBox"), for: .normal)
            self.btnSave.setImage(UIImage(named: ""), for: .normal)
            self.btnSave.setTitle("Save", for: .normal)
          
            self.btnPartyCloud.backgroundColor = UIColor(hexString: "#FFC805")
            self.btnPartyCloud.setTitleColor(UIColor(hexString: "#000000"), for: .normal)
            self.btnSunny.backgroundColor = UIColor(hexString: "#007AFF")
            self.btnSunny.setTitleColor(UIColor(hexString: "#FBFCFC"), for: .normal)
            self.btnCloudCover.backgroundColor = UIColor(hexString: "#007AFF")
            self.btnCloudCover.setTitleColor(UIColor(hexString: "#FBFCFC"), for: .normal)
            self.btnCross.backgroundColor = UIColor(red: 186/255, green: 11/255, blue: 11/255, alpha: 0.3)
            
            self.btnSave.backgroundColor = UIColor(hexString: "#9BA5B9")
            if Store.isPause == true{
                self.lblProgressStatus.text = "(paused)"
                self.lblProgressStatus.textColor = UIColor(hexString: "#FFE600")
                btnPause.setTitle("Resume", for: .normal)
                btnPause.borderCol = UIColor(hexString: "#FFFFFF")
                btnPause.borderWid = 1
                self.btnCross.isUserInteractionEnabled = true
                self.btnPause.isUserInteractionEnabled = true
                self.btnSave.isUserInteractionEnabled = false
                self.btnPause.setImage(UIImage(named: ""), for: .normal)
                self.btnPause.backgroundColor = UIColor(red: 81/255, green: 175/255, blue: 96/255, alpha: 0.3)
            }else{
         
                if Store.counter >= 900{
                    self.btnSave.backgroundColor = UIColor(hexString: "#67CE67")
                    self.lblProgressStatus.text = "(Complete)"
                    self.lblProgressStatus.textColor = UIColor(hexString: "#52FFA2")
                    self.btnCross.isUserInteractionEnabled = true
                    self.btnPause.isUserInteractionEnabled = false
                    self.btnSave.isUserInteractionEnabled = true
                    self.btnPause.setImage(UIImage(named: "Text Button 4"), for: .normal)
                    self.btnPause.setTitle("", for: .normal)
                    self.btnPause.borderCol = .clear
                    self.btnPause.borderWid = 0
                    self.btnPause.backgroundColor = UIColor(hexString: "#9BA5B9")
                }else{
                    self.btnSave.backgroundColor = UIColor(hexString: "#9BA5B9")
                    self.lblProgressStatus.text = "(tracking)"
                    self.lblProgressStatus.textColor = UIColor(hexString: "#52FFA2")
                    self.btnCross.isUserInteractionEnabled = true
                    self.btnPause.isUserInteractionEnabled = true
                    self.btnSave.isUserInteractionEnabled = false
                    self.btnPause.setImage(UIImage(named: ""), for: .normal)
                    btnPause.setTitle("Pause", for: .normal)
                    self.btnPause.borderCol = UIColor(hexString: "#FFFFFF")
                    self.btnPause.borderWid = 1
                    self.btnPause.backgroundColor = UIColor(red: 81/255, green: 175/255, blue: 96/255, alpha: 0.3)
                }
                }
           
        }else if Store.startMinute == "30"{
            btnPause.isHidden = false
            btnSave.isHidden = false
            btnCross.isHidden = false
            linearProgressVw.maximumValue = 1800
            self.btnSunny.isUserInteractionEnabled = false
            self.btnPartyCloud.isUserInteractionEnabled = false
            self.btnCloudCover.isUserInteractionEnabled = false
            self.btnSunny.setImage(UIImage(named: "Text Button"), for: .normal)
            self.btnPartyCloud.setImage(UIImage(named: "Text Button 1"), for: .normal)
            self.btnCloudCover.setImage(UIImage(named: ""), for: .normal)
            self.btnCross.setImage(UIImage(named: "TextBox"), for: .normal)
            self.btnSave.setImage(UIImage(named: ""), for: .normal)
            self.btnSunny.setTitle("", for: .normal)
            self.btnPartyCloud.setTitle("", for: .normal)
            self.btnCloudCover.setTitle("☁️ Cloud Cover (30 minutes)", for: .normal)
            self.btnSave.setTitle("Save", for: .normal)
            self.btnCloudCover.backgroundColor = UIColor(hexString: "#FFC805")
            self.btnCloudCover.setTitleColor(UIColor(hexString: "#000000"), for: .normal)
            self.btnSunny.backgroundColor = UIColor(hexString: "#007AFF")
            self.btnSunny.setTitleColor(UIColor(hexString: "#FBFCFC"), for: .normal)
            self.btnPartyCloud.backgroundColor = UIColor(hexString: "#007AFF")
            self.btnPartyCloud.setTitleColor(UIColor(hexString: "#FBFCFC"), for: .normal)
            self.btnCross.backgroundColor = UIColor(red: 186/255, green: 11/255, blue: 11/255, alpha: 0.3)
           
            self.btnSave.backgroundColor = UIColor(hexString: "#9BA5B9")
            if Store.isPause == true{
                self.lblProgressStatus.text = "(paused)"
                self.lblProgressStatus.textColor = UIColor(hexString: "#FFE600")
                btnPause.setTitle("Resume", for: .normal)
                btnPause.borderCol = UIColor(hexString: "#FFFFFF")
                btnPause.borderWid = 1
                timer?.invalidate()
                timer = nil
                self.btnCross.isUserInteractionEnabled = true
                self.btnPause.isUserInteractionEnabled = true
                self.btnSave.isUserInteractionEnabled = false
                self.btnPause.setImage(UIImage(named: ""), for: .normal)
                self.btnPause.backgroundColor = UIColor(red: 81/255, green: 175/255, blue: 96/255, alpha: 0.3)
            }else{
                
                if Store.counter >= 1800{
                    self.btnSave.backgroundColor = UIColor(hexString: "#67CE67")
                    self.lblProgressStatus.text = "(Complete)"
                    self.lblProgressStatus.textColor = UIColor(hexString: "#52FFA2")
                    self.btnCross.isUserInteractionEnabled = true
                    self.btnPause.isUserInteractionEnabled = false
                    self.btnSave.isUserInteractionEnabled = true
                    self.btnPause.setImage(UIImage(named: "Text Button 4"), for: .normal)
                    self.btnPause.setTitle("", for: .normal)
                    self.btnPause.borderCol = .clear
                    self.btnPause.borderWid = 0
                    self.btnPause.backgroundColor = UIColor(hexString: "#9BA5B9")
                }else{
                    self.btnSave.backgroundColor = UIColor(hexString: "#9BA5B9")
                    self.lblProgressStatus.text = "(tracking)"
                    self.lblProgressStatus.textColor = UIColor(hexString: "#52FFA2")
                    self.btnCross.isUserInteractionEnabled = true
                    self.btnPause.isUserInteractionEnabled = true
                    self.btnSave.isUserInteractionEnabled = false
                    self.btnPause.setImage(UIImage(named: ""), for: .normal)
                    btnPause.setTitle("Pause", for: .normal)
                    self.btnPause.borderCol = UIColor(hexString: "#FFFFFF")
                    self.btnPause.borderWid = 1
                    self.btnPause.backgroundColor = UIColor(red: 81/255, green: 175/255, blue: 96/255, alpha: 0.3)
                }
                
                }
        }else{
            btnPause.isHidden = true
            btnSave.isHidden = true
            btnCross.isHidden = true
            linearProgressVw.maximumValue = 0
            lblTimer.text = "00:00"
            self.btnSunny.backgroundColor = UIColor(hexString: "007AFF")
            self.btnSunny.setTitleColor(UIColor(hexString: "#FBFCFC"), for: .normal)
            self.btnPartyCloud.backgroundColor = UIColor(hexString: "007AFF")
            self.btnPartyCloud.setTitleColor(UIColor(hexString: "#FBFCFC"), for: .normal)
            self.btnCloudCover.backgroundColor = UIColor(hexString: "007AFF")
            self.btnCloudCover.setTitleColor(UIColor(hexString: "#FBFCFC"), for: .normal)
            self.btnCross.backgroundColor = UIColor(hexString: "#9BA5B9")
            self.btnPause.backgroundColor = UIColor(hexString: "#9BA5B9")
            self.btnSave.backgroundColor = UIColor(hexString: "#9BA5B9")
            self.btnPause.setTitle("", for: .normal)
            self.btnSave.setTitle("", for: .normal)
            self.btnPause.borderCol = UIColor(hexString: "#FFFFFF")
            self.btnPause.borderWid = 0
            self.lblProgressStatus.text = "(select a timer)"
            self.lblProgressStatus.textColor = UIColor(hexString: "##9BA5B9")
            self.btnCross.isUserInteractionEnabled = false
            self.btnPause.isUserInteractionEnabled = false
            self.btnSave.isUserInteractionEnabled = false
            self.btnSunny.isUserInteractionEnabled = true
            self.btnPartyCloud.isUserInteractionEnabled = true
            self.btnCloudCover.isUserInteractionEnabled = true
            self.btnSunny.setImage(UIImage(named: ""), for: .normal)
            self.btnPartyCloud.setImage(UIImage(named: ""), for: .normal)
            self.btnCloudCover.setImage(UIImage(named: ""), for: .normal)
            self.btnCross.setImage(UIImage(named: "Text Button 3"), for: .normal)
            self.btnPause.setImage(UIImage(named: "Text Button 4"), for: .normal)
            self.btnSave.setImage(UIImage(named: "Text Button 5"), for: .normal)
            self.btnSunny.setTitle("☀️ Sunny (5 minutes)", for: .normal)
            self.btnPartyCloud.setTitle("⛅ Partly Cloudy (15 minutes)", for: .normal)
            self.btnCloudCover.setTitle("☁️ Cloud Cover (30 minutes)", for: .normal)
            
        }
    }
   
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func getTodayDate(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        todayDate = dateString
    }
    
    func rotateImage(imageView: UIImageView, angle: CGFloat) {
        
        let rotationTransform = CGAffineTransform(rotationAngle: -angle)
        imageView.transform = rotationTransform
    }
   
    func calculateInclineDegree(altitude: Double, distance: Double) -> Double {
        
        let radianAngle = atan(altitude / distance)
        let degreeAngle = radiansToDegrees(radianAngle)
        return degreeAngle
    }
    
    func radiansToDegrees(_ radians: Double) -> Double {
        
        return radians * 180.0 / Double.pi
    }
    
    func updateSunPosition(imageView: UIImageView, angle: CGFloat) {
        
        let radians = -angle * .pi / 180
        let radius: CGFloat = 20
        let newX =  radius * cos(radians)
        let newY =  radius * sin(radians)
        imageView.transform = CGAffineTransform(translationX: newX, y: newY)
    }
    
    func updateMoonPosition(imageView: UIImageView, angle: CGFloat) {
        
        let radians = -angle * .pi / 180
        let radius: CGFloat = 20
        let newX =  radius * cos(radians)
        let newY =  radius * sin(radians)
        imageView.transform = CGAffineTransform(translationX: newX, y: newY)
    }
    
    //MARK: - ACTIONS
    
    @IBAction func actionBack(_ sender: UIButton) {
        
        stopTimerTest()
        self.navigationController?.popViewController(animated: true)
        callBack?()
    }
    
    @IBAction func actionSunny(_ sender: UIButton) {
//        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let generator = UIImpactFeedbackGenerator(style: .soft)
           generator.impactOccurred()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpVC") as! PopUpVC
        vc.modalPresentationStyle = .overFullScreen
        vc.isComing = "5"
        vc.jumpAnimation()
        vc.callBack = { (type) in
            Store.startTimer = true
            Store.startMinute = "5"
            Store.counter = 0

            self.startTimer()
            self.setTimerData()
        }
        self.navigationController?.present(vc, animated: false)
    }

    @IBAction func actionPartyCloud(_ sender: UIButton) {
//        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let generator = UIImpactFeedbackGenerator(style: .soft)
           generator.impactOccurred()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpVC") as! PopUpVC
        vc.modalPresentationStyle = .overFullScreen
        vc.isComing = "15"
        vc.jumpAnimation()
        vc.callBack = { (type) in
            Store.startMinute = "15"
            Store.startTimer = true
            Store.counter = 0

            self.startTimer()
            self.setTimerData()
        }
        self.navigationController?.present(vc, animated: false)
    }
    
    @IBAction func actionCloudCover(_ sender: UIButton) {
//        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let generator = UIImpactFeedbackGenerator(style: .soft)
           generator.impactOccurred()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpVC") as! PopUpVC
        vc.modalPresentationStyle = .overFullScreen
        vc.isComing = "30"
        vc.jumpAnimation()
        vc.callBack = { (type) in
            Store.startMinute = "30"
            Store.startTimer = true
            Store.counter = 0
            self.startTimer()
            self.setTimerData()
            
        }
        self.navigationController?.present(vc, animated: false)
    }
    
    @objc func timerAction() {
        
        if Store.startMinute == "5"{
            if Store.counter < 300{
                Store.counter += 1
                lblTimer.text = "\(timeFormatted(Store.counter))"
                linearProgressVw.setProgress(Float(Store.counter), animated: true)
            }else{
                timer?.invalidate()
                timer = nil
            }
        }else if Store.startMinute == "15"{
            if Store.counter < 900{
                Store.counter += 1
                lblTimer.text = "\(timeFormatted(Store.counter))"
                linearProgressVw.setProgress(Float(Store.counter), animated: true)
            }else{
                timer?.invalidate()
                timer = nil
            }
        }else{
            if Store.counter < 1800{
                Store.counter += 1
                lblTimer.text = "\(timeFormatted(Store.counter))"
                linearProgressVw.setProgress(Float(Store.counter), animated: true)
               
            }else{
                timer?.invalidate()
                timer = nil
            }
        }
        setTimerData()

       }
    
    @IBAction func actionCross(_ sender: UIButton) {
//        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
       
        let generator = UIImpactFeedbackGenerator(style: .soft)
           generator.impactOccurred()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpVC") as! PopUpVC
        vc.modalPresentationStyle = .overFullScreen
        vc.jumpAnimation()
        vc.isComing = "Cancel"
        vc.callBack = { (type) in
            Store.startMinute = ""
            Store.counter = 0
            Store.startTimer = false
            Store.isPause = false
            self.stopTimerTest()
            self.setTimerData()
        }
        self.navigationController?.present(vc, animated: false)
      
    }
    
    @IBAction func actionPause(_ sender: UIButton) {
        if Store.isPause == false{
//            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            let generator = UIImpactFeedbackGenerator(style: .soft)
               generator.impactOccurred()
            Store.isPause = true
            Store.startTimer = false
            self.stopTimerTest()
        }else{
//            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            let generator = UIImpactFeedbackGenerator(style: .soft)
               generator.impactOccurred()
            self.btnPause.setTitle("Pause", for: .normal)
            Store.isPause = false
            Store.startTimer = true
            self.startTimer()
        }
       
        setTimerData()
    }
    @IBAction func actionSave(_ sender: UIButton) {
//        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let generator = UIImpactFeedbackGenerator(style: .soft)
           generator.impactOccurred()
        Store.solarSummary?.append(["date":todayDate,"time":Store.startMinute])
        Store.startMinute = ""
        Store.counter = 0
        Store.startTimer = false
        self.stopTimerTest()
        setTimerData()
        
    }
}

//MARK: - LOCATION DELEGATE METHOD

extension CompassVC:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let rotationAngle = CGFloat(newHeading.trueHeading.toRadians)
        //        rotateImageAccordingToClock(imageView: imgVwCompass, angle: rotationAngle)
        rotateImage(imageView: imgVwCompass, angle:rotationAngle)
        
        let roundedAngle = Int(newHeading.trueHeading)
        //        let position = Int(sunAngle)
        let setPosition = CGFloat(360-sunAngle)
        updateSunPosition(imageView: imgVwSun, angle: setPosition+CGFloat(compassAngle)+90)
        let setPositionMoon = CGFloat(360-sunAngle)
        updateMoonPosition(imageView: imgVwMoon, angle: setPositionMoon+CGFloat(compassAngle)-90)
        compassAngle = roundedAngle
        if(roundedAngle >= 0 && roundedAngle < Int(22.5)){
            lblAngle.text = "\(roundedAngle)° N"
            selfDirection = "N"
        } else if (roundedAngle >= Int(22.5) && roundedAngle < Int(45)){
            lblAngle.text = "\(roundedAngle)° NNE"
            selfDirection = "NNE"
        }else if (roundedAngle >= Int(45) && roundedAngle < Int(67.5)){
            lblAngle.text = "\(roundedAngle)° NE"
            selfDirection = "NE"
        }else if (roundedAngle >= Int(67.5) && roundedAngle < Int(90)){
            lblAngle.text = "\(roundedAngle)° ENE"
            selfDirection = "ENE"
        }else if (roundedAngle >= Int(90) && roundedAngle < Int(112.5)){
            lblAngle.text = "\(roundedAngle)° E"
            selfDirection = "E"
        }else if (roundedAngle >= Int(112.5) && roundedAngle < Int(135)){
            lblAngle.text = "\(roundedAngle)° ESE"
            selfDirection = "ESE"
        }else if (roundedAngle >= Int(135) && roundedAngle < Int(157.5)){
            lblAngle.text = "\(roundedAngle)° SE"
            selfDirection = "SE"
        }else if (roundedAngle >= Int(157.5) && roundedAngle < Int(180)){
            lblAngle.text = "\(roundedAngle)° SSE"
            selfDirection = "SSE"
        }else if (roundedAngle >= Int(180) && roundedAngle < Int(202.5)){
            lblAngle.text = "\(roundedAngle)° S"
            selfDirection = "S"
        }else if (roundedAngle >= Int(202.5) && roundedAngle < Int(225)){
            lblAngle.text = "\(roundedAngle)° SSW"
            selfDirection = "SSW"
        }else if (roundedAngle >= Int(225) && roundedAngle < Int(247.5)){
            lblAngle.text = "\(roundedAngle)° SW"
            selfDirection = "SW"
        }else if (roundedAngle >= Int(247.5) && roundedAngle < Int(270)){
            lblAngle.text = "\(roundedAngle)° WSW"
            selfDirection = "WSW"
        }else if (roundedAngle >= Int(270) && roundedAngle < Int(292.5)){
            lblAngle.text = "\(roundedAngle)° W"
            selfDirection = "W"
        }else if (roundedAngle >= Int(292.5) && roundedAngle < Int(315)){
            lblAngle.text = "\(roundedAngle)° WNW"
            selfDirection = "WNW"
        }else if (roundedAngle >= Int(315) && roundedAngle < Int(337.5)){
            lblAngle.text = "\(roundedAngle)° NW"
            selfDirection = "NW"
        }else{
            lblAngle.text = "\(roundedAngle)° NNW"
            selfDirection = "NNW"
            
        }
        if nowTime > sunRise && nowTime < sunSet{
            imgVwSun.image = UIImage(named: "SUN")
            imgVwMoon.isHidden = true
            let rotateAngle = (360-compassAngle) + sunAngle
            if rotateAngle >= 313 && rotateAngle <= 406{
               
                imgVwCompass.image = UIImage(named: "Group 5 (2)")
                imgVwRotateCompass.image = UIImage(named: "Group 15")
                imgVwArrow.image = UIImage(named: "Arrow 1")
               
            }else{
               
                imgVwCompass.image = UIImage(named: "Group 1171276326 (1)")
                imgVwRotateCompass.image = UIImage(named: "Group 14")
                imgVwArrow.image = UIImage(named: "Arrow")
               
            }
        }else{
            imgVwCompass.image = UIImage(named: "Group 1171276326 (1)")
            imgVwMoon.isHidden = false
            imgVwSun.image = UIImage(named: "SUN 1")
            imgVwRotateCompass.image = UIImage(named: "Group 13")
            imgVwArrow.image = UIImage(named: "Arrow 2")
           
        }
    }
    
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    guard let location = locations.last else {

        return
    }
    lat = location.coordinate.latitude
    long = location.coordinate.longitude
    if lat != 0 {
        UserDefaults.standard.set(true, forKey: "fetchLatLong")
        imgVwSun.isHidden = false
    }else{
        UserDefaults.standard.set(false, forKey: "fetchLatLong")
        imgVwSun.isHidden = true
    }
    let geocoder = CLGeocoder()
    let locations = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

           geocoder.reverseGeocodeLocation(locations) { (placemarks, error) in
               if let error = error {
                   print("Geocoding error: \(error.localizedDescription)")
                   return
               }

               if let placemark = placemarks?.first {
                   let locality = placemark.locality ?? ""
                   let administrativeArea = placemark.administrativeArea ?? ""
                   let address = "\(locality), \(administrativeArea)"
                   self.lblAddress.text = address
               }
           }
    let naplesLocation: CLLocation = .init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    let timeZoneNaples = TimeZone.current
    let mySun: Sun = .init(location: naplesLocation, timeZone: timeZoneNaples)
    let myDate: Date = Date()
    mySun.setDate(myDate)
    sunAngle = Int(mySun.azimuth.degrees)
    let value = mySun.azimuth.degrees
    let index = Int(value/22.5) % 16
    sunDirection = directions[index]
    maxSunRadius = sunAngle + 39
    minSunRadius = sunAngle - 39
    let dateFormatterTime = DateFormatter()
    dateFormatterTime.dateFormat = "HH.mm"
    let sunRiseTime = dateFormatterTime.string(from: mySun.sunrise)
    let sunSetTime = dateFormatterTime.string(from: mySun.sunset)
    let nowDayTime = dateFormatterTime.string(from: Date())
    sunRise = Double(sunRiseTime) ?? 0
    sunSet = Double(sunSetTime) ?? 0
    nowTime = Double(nowDayTime) ?? 0
    lblSolarAngle.text = "\(Int(mySun.altitude.degrees))°"
    let setPosition = CGFloat(360-sunAngle)
    updateSunPosition(imageView: imgVwSun, angle: setPosition+CGFloat(compassAngle)+90)
    let setPositionMoon = CGFloat(360-sunAngle)
    updateMoonPosition(imageView: imgVwMoon, angle: setPositionMoon+CGFloat(compassAngle)-90)
}
    
}
