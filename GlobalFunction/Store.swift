//
//  Store.swift
//  DLE
//
//  Created by meet sharma on 09/06/23.
//

import Foundation
enum DefaultKeys: String{
    case outSide
    case startMinute
    case counter
    case isPause
    case solarSummary
    case timerStatus
    case sunDetail
    case sunAngle
    case angleTime
    case startTimer
    case isReverse
}
class Store {
    class var outSide: Bool?{
        set{
            Store.saveValue(newValue, .outSide)
        }get{
            return Store.getValue(.outSide) as? Bool ?? false
        }
    }
    class var startTimer: Bool?{
        set{
            Store.saveValue(newValue, .startTimer)
        }get{
            return Store.getValue(.startTimer) as? Bool ?? false
        }
    }
   
   
    class var solarSummary: [[String:Any]]? {
        set{
            Store.saveValue(newValue, .solarSummary)
        }get{
            return Store.getValue(.solarSummary) as? [[String:Any]] ?? [[:]]
        }
        }
    class var sunDetail: [String:Any]? {
        set{
            Store.saveValue(newValue, .sunDetail)
        }get{
            return Store.getValue(.sunDetail) as? [String:Any] ?? [:]
        }
        }
    class var isPause: Bool?{
        set{
            Store.saveValue(newValue, .isPause)
        }get{
            return Store.getValue(.isPause) as? Bool ?? false
        }
    }

    class var startMinute: String{
        set{
            Store.saveValue(newValue, .startMinute)
        }get{
            return Store.getValue(.startMinute) as? String ?? ""
        }
    }
    class var counter: Int{
        set{
            Store.saveValue(newValue, .counter)
        }get{
            return Store.getValue(.counter) as? Int ?? 0
        }
    }
    class var sunAngle: Int{
        set{
            Store.saveValue(newValue, .sunAngle)
        }get{
            return Store.getValue(.sunAngle) as? Int ?? 0
        }
    }
    class var angleTime: Double{
        set{
            Store.saveValue(newValue, .angleTime)
        }get{
            return Store.getValue(.angleTime) as? Double ?? 0
        }
    }
    class var timerStatus: String{
        set{
            Store.saveValue(newValue, .timerStatus)
        }get{
            return Store.getValue(.timerStatus) as? String ?? ""
        }
    }

    //MARK:-  Private Functions
    
    
    private class func saveUserDetails<T: Codable>(_ value: T?, _ key: DefaultKeys){
        var data: Data?
        if let value = value{
            data = try? PropertyListEncoder().encode(value)
        }
        Store.saveValue(data, key)
    }
    
    private class func getUserDetails<T: Codable>(_ key: DefaultKeys) -> T?{
        if let data = self.getValue(key) as? Data{
            let loginModel = try? PropertyListDecoder().decode(T.self, from: data)
            return loginModel
        }
        return nil
    }
    private class func saveValue(_ value: Any? ,_ key:DefaultKeys){
        var data: Data?
        if let value = value{
            data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true)
        }
        UserDefaults.standard.set(data, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    private class func getValue(_ key: DefaultKeys) -> Any{
        if let data = UserDefaults.standard.value(forKey: key.rawValue) as? Data{
            if let value = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
            {
                return value
            }
            else{
                return ""
            }
        }else{
            return ""
        }
    }
}
