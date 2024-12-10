//
//  BackgroundTimer.swift
//  DLE
//
//  Created by Apple on 18/07/23.
//

import Foundation
import UIKit

class BackgroundTimer {
    private var timer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func start() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        registerBackgroundTask()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        endBackgroundTask()
    }

    @objc private func timerTick() {
        // Update UI or perform background task here
        print("Timer tick")
        timerActionBackground()
    }

    @objc func timerActionBackground() {
       
        if Store.startMinute == "5"{
            if Store.counter < 300{
                Store.counter = Store.counter + 1
            }else{
                stop()
            }
        }else if Store.startMinute == "15"{
            if Store.counter < 900{
                Store.counter = Store.counter + 1

            }else{
                stop()
            }
        }else{
            if Store.counter < 1800{
                Store.counter = Store.counter + 1
            }else{
                stop()
            }
        }

       }
    private func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
}

