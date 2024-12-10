//
//  DailySunVC.swift
//  DLE
//
//  Created by meet sharma on 12/07/23.
//

import UIKit
import CoreLocation
import SunKit
import CoreMotion
import Solar
import QuartzCore
import AudioToolbox

class DailySunVC: UIViewController {
    
    //MARK: - OUTLETS
    
    @IBOutlet weak var imgVwRotateAngle: UIImageView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var lblAngle: UILabel!
    @IBOutlet weak var lblSolarAngle: UILabel!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var lblSunriseTime: UILabel!
    @IBOutlet weak var lblSunsetTime: UILabel!
    @IBOutlet weak var vwSolarAngle: UIView!
    
    @IBOutlet weak var rotateSunCenterX: NSLayoutConstraint!
    @IBOutlet weak var rotateSunCenterY: NSLayoutConstraint!
    @IBOutlet weak var imgVwRotateSum: UIImageView!
    @IBOutlet weak var imgVwMoon: UIImageView!
    @IBOutlet weak var imgVwCompass: UIImageView!
    @IBOutlet weak var lblElevation: CircularLabel!
    @IBOutlet weak var sunImgCenterX: NSLayoutConstraint!
    @IBOutlet weak var sunImgCenterY: NSLayoutConstraint!
    @IBOutlet weak var lblLatitude: CircularLabel!
    @IBOutlet weak var lblLongitude: CircularLabel!
    @IBOutlet weak var lblIncline: CircularLabel!
    @IBOutlet weak var imgVwArrow: UIImageView!
    @IBOutlet weak var imgVwRotateCompass: UIImageView!
    @IBOutlet weak var imgVwSun: UIImageView!
    @IBOutlet weak var vwSun: UIView!
    @IBOutlet weak var btnOnOff: UIButton!
    
    //MARK: - VARIABLES
    let locationManager = CLLocationManager()
    var sunDirectionIndex = 0
    var sunDirection = ""
    var sunAngle = 0
    var timer: Timer?
    var backgroundTimer: Timer?
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
    var isOn = false
    
    var sunRiseHour = 0
    var sunRiseMin = 0
    var sunSetHour = 0
    var sunSetMin = 0
    var sunNowHour = 0
    var sunNowMin = 0
    var isMove = false
    var count = 0
    var maxValue = 10
    
    //MARK: - LIFE CYCLE METHOD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiSet()
    }
    
    //MARK: - FUNCTIONS
    
    func uiSet(){
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        updateSunPositionAngle(imageView: imgVwRotateSum, angle: CGFloat(10))
        if Store.outSide == true{
            self.btnOnOff.isSelected = true
            self.isOn = true
            btnStart.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        }else{
            self.btnOnOff.isSelected = false
            self.isOn = false
            btnStart.backgroundColor = UIColor(red: 57/255, green: 57/255, blue: 61/255, alpha: 1.0)
        }
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
       
    }
    
    func startTimer(){
        
        self.backgroundTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerActionBackground), userInfo: nil, repeats: true)
    }
    
    func stopTimerTest() {
        
      backgroundTimer?.invalidate()
      backgroundTimer = nil
        
    }
    
    @objc func updateTime(){
      
        let date = Date()
        let dateFormatters = DateFormatter()
        dateFormatters.dateFormat = "hh:mm a"
        let currentTime = dateFormatters.string(from: date)
        lblCurrentTime.text = currentTime
        
    }
    @objc func timerActionBackground() {
       
        if Store.startMinute == "5"{
            if Store.counter < 300{
                Store.counter += 1
            }else{
                backgroundTimer?.invalidate()
                backgroundTimer = nil
            }
        }else if Store.startMinute == "15"{
            if Store.counter < 900{
                Store.counter += 1

            }else{
                backgroundTimer?.invalidate()
                backgroundTimer = nil
            }
        }else{
            if Store.counter < 1800{
                Store.counter += 1
            }else{
                backgroundTimer?.invalidate()
                backgroundTimer = nil
            }
        }

       }
    
    @objc func timerAction() {
        
        if count < maxValue{
            count += 1
            print(count)
            updateSunPositionAngle(imageView: imgVwRotateSum, angle: CGFloat(count))
        }else{
            timer?.invalidate()
            timer = nil
        }
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
    func updateSunPositionAngle(imageView: UIImageView, angle: CGFloat) {
        let radians = angle * .pi / 180
        let radius: CGFloat = -95
        let newX =  radius * cos(radians)
        let newY =  radius * sin(radians)
        imageView.transform = CGAffineTransform(translationX: newX, y: newY)
     
    }
    func updateSunPosition(imageView: UIImageView, angle: CGFloat) {
        let radians = -angle * .pi / 180
  
        let radius: CGFloat = 57
        let newX =  radius * cos(radians)
        let newY =  radius * sin(radians)
        imageView.transform = CGAffineTransform(translationX: newX, y: newY)
    }
    func updateMoonPosition(imageView: UIImageView, angle: CGFloat) {
        let radians = -angle * .pi / 180
  
        let radius: CGFloat = 65
        let newX =  radius * cos(radians)
        let newY =  radius * sin(radians)
        imageView.transform = CGAffineTransform(translationX: newX, y: newY)
    }
    func getHourAndMinute(time:String,sunType:String){
        let dateFormatter = DateFormatter()
              dateFormatter.dateFormat = "H:mm"
              guard let date = dateFormatter.date(from: time) else {
                  return
              }
              let calendar = Calendar.current
              let components = calendar.dateComponents([.hour, .minute], from: date)
              
              if let hour = components.hour, let minute = components.minute {
               
                  if sunType == "sunRise"{
                      sunRiseHour = hour
                      sunRiseMin = minute
                  }else if sunType == "sunSet"{
                      sunSetHour = hour
                      sunSetMin = minute
                  }else{
                      sunNowHour = hour
                      sunNowMin = minute
                  }
                 
              }
        Store.sunDetail = ["sunRiseHour":sunRiseHour,"sunRiseMin":sunRiseMin,"sunSetHour":sunSetHour,"sunSetMin":sunSetMin,"sunNowHour":sunNowHour,"sunNowMin":sunNowMin]
    }
    
    func getSunTotalTime(startHour:Int,startMin:Int,endHour:Int,endMin:Int,now:Bool){
        let calendar = Calendar.current
               var firstTimeComponents = DateComponents()
               firstTimeComponents.hour = startHour
               firstTimeComponents.minute = startMin
               let firstTime = calendar.date(from: firstTimeComponents)!
               var secondTimeComponents = DateComponents()
               secondTimeComponents.hour = endHour
               secondTimeComponents.minute = endMin
               let secondTime = calendar.date(from: secondTimeComponents)!
               let minuteDifference = calendar.dateComponents([.minute], from: firstTime, to: secondTime).minute ?? 0
               print("Minute: \(minuteDifference) minutes")
        
              
        if now == false{
            let dividend = minuteDifference
            let divisor = 160
            let result = Double(dividend) / Double(divisor)
            let formattedNumber = String(format: "%.2f", result)
            Store.angleTime = Double(formattedNumber) ?? 0
            print(formattedNumber)
            
        }else{
            if nowTime > sunRise && nowTime < sunSet{

                let dividend = minuteDifference
                let divisor = Store.angleTime
                let angle = Double(dividend) / Double(divisor)
                let nowSunAngle = Int(angle)
                print("Now sun angle: \(nowSunAngle)")
                maxValue = nowSunAngle+10
                self.timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
//                updateSunPositionAngle(imageView: imgVwRotateSum, angle: CGFloat(nowSunAngle+10))
            }else{
                maxValue = 170
                self.timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)

            }
        }
               
                                
               
    }
    //MARK: - ACTIONS
    
    @IBAction func actionOnOff(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
//            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            let generator = UIImpactFeedbackGenerator(style: .soft)
               generator.impactOccurred()
            isOn = true
            Store.outSide = true
            btnStart.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        }else{
//            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            let generator = UIImpactFeedbackGenerator(style: .soft)
               generator.impactOccurred()
            isOn = false
            Store.outSide = false
            btnStart.backgroundColor = UIColor(red: 57/255, green: 57/255, blue: 61/255, alpha: 1.0)
        }
    }
    
    @IBAction func actionStartLight(_ sender: UIButton) {
        
        self.stopTimerTest()
        if isOn == true{
//            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            let generator = UIImpactFeedbackGenerator(style: .soft)
               generator.impactOccurred()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CompassVC") as! CompassVC
            vc.callBack = {
                if Store.startTimer == true{
                    self.startTimer()
                }
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
           
        }
    }
    
   
      }

//MARK: - LOCATION DELEGATE METHOD

extension DailySunVC:CLLocationManagerDelegate{
    
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
                imgVwCompass.image = UIImage(named: "Group 2")
                imgVwRotateCompass.image = UIImage(named: "Group 15")
                imgVwArrow.image = UIImage(named: "Arrow 1")
              
            }else{
                
                imgVwCompass.image = UIImage(named: "Group 1")
                imgVwRotateCompass.image = UIImage(named: "Group 14")
                imgVwArrow.image = UIImage(named: "Arrow")
            }
        }else{
            imgVwCompass.image = UIImage(named: "Group 1")
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
    let lat = Float(mySun.location.coordinate.latitude)
    lblLatitude.text = "\(lat)"
    let value = mySun.azimuth.degrees
    let index = Int(value/22.5) % 16
    sunDirection = directions[index]
    let altitude: Double = location.altitude
    let distance: Double = 70
    let inclineDegree = calculateInclineDegree(altitude: altitude, distance: distance)
    let incline = Int(inclineDegree)
    lblIncline.text = "I N C L I N E   \(incline)  º"
    let elevationInMeters = Int(location.altitude)
    lblElevation.text = "E L E V A T I O N   \(elevationInMeters) M"
    let long = Float(mySun.location.coordinate.longitude)
    lblLongitude.text = "\(long)"
    maxSunRadius = sunAngle + 39
    minSunRadius = sunAngle - 39
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "hh:mm"
    let formattedSunrise = dateFormatter.string(from: mySun.sunrise)
    let formattedSunset = dateFormatter.string(from: mySun.sunset)
    lblSunriseTime.text = formattedSunrise
    lblSunsetTime.text = formattedSunset

    let dateFormatterTime = DateFormatter()
    dateFormatterTime.dateFormat = "HH.mm"
    let sunRiseTime = dateFormatterTime.string(from: mySun.sunrise)
    let sunSetTime = dateFormatterTime.string(from: mySun.sunset)
    let nowDayTime = dateFormatterTime.string(from: Date())
    sunRise = Double(sunRiseTime) ?? 0
    sunSet = Double(sunSetTime) ?? 0
    nowTime = Double(nowDayTime) ?? 0
    getHourAndMinute(time: sunRiseTime, sunType: "sunRise")
    getHourAndMinute(time: sunSetTime, sunType: "sunSet")
    getHourAndMinute(time: nowDayTime, sunType: "sunNow")
    getSunTotalTime(startHour: Store.sunDetail?["sunRiseHour"] as? Int ?? 0, startMin:  Store.sunDetail?["sunRiseMin"] as? Int ?? 0, endHour:  Store.sunDetail?["sunSetHour"] as? Int ?? 0, endMin:  Store.sunDetail?["sunSetMin"] as? Int ?? 0, now: false)
    getSunTotalTime(startHour: Store.sunDetail?["sunRiseHour"] as? Int ?? 0, startMin:  Store.sunDetail?["sunRiseMin"] as? Int ?? 0, endHour:  Store.sunDetail?["sunNowHour"] as? Int ?? 0, endMin:  Store.sunDetail?["sunNowMin"] as? Int ?? 0, now: true)
    
    lblSolarAngle.text = "\(Int(mySun.altitude.degrees))º"
    
    let setPosition = CGFloat(360-sunAngle)
    updateSunPosition(imageView: imgVwSun, angle: setPosition+CGFloat(compassAngle)+90)
    let setPositionMoon = CGFloat(360-sunAngle)
    updateMoonPosition(imageView: imgVwMoon, angle: setPositionMoon+CGFloat(compassAngle)-90)
}
}


