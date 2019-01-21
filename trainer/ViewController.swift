//
//  ViewController.swift
//  trainer
//
//  Created by Vladislav Matus on 19/01/2019.
//  Copyright © 2019 Vladislav Matus. All rights reserved.
//

import UIKit
import AudioToolbox

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var iterationLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var startstopButton: UIButton!
    
    
    var isOn = false
    var timer = Timer()
    var counterValues = [5000,1000]
    var usedCounterSum = 0
    var counterIndex = 0
    var startTimestamp = Int64(0)
    var stopTimestamp = Int64(0)
    
    func formatTime(timeInt:Int) -> String {
        let seconds = Int(timeInt/1000)
        let (m,s) = (seconds / 60, (seconds % 3600) % 60)
        if m < 100 {
            return String(format:"%02i:%02i", m, s )
        }
        else {
            return String(format:"--:%02i", s )
        }
    }
    
    func getTimer() -> Int {
        return Int(Date().toMillis() - startTimestamp)
    }
    func getMinutesString(timeInt:Int) -> String {
        if (timeInt / 60000 > 9) {
            return "#"
        }
        return String(timeInt / 60000)
    }
    func getSeconds(timeInt:Int) -> Int {
        return ((timeInt / 1000) % 3600) % 60
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        minutesLabel.text = "0"
        secondsLabel.text = "00"
    }

    @IBAction func buttonClicked(_ sender: UIButton) {
        isOn = !isOn
        if isOn {
            startTimestamp += Date().toMillis() - stopTimestamp
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
            startstopButton.setTitle("STOP", for: .normal)
        }
        else {
            stopTimestamp = Date().toMillis()
            startstopButton.setTitle("START", for: .normal)
            timer.invalidate()
        }
    }
    
    @objc func UpdateTimer() {
        var remaining = counterValues[counterIndex] - getTimer() + usedCounterSum
        if (remaining <= 0) {
            usedCounterSum = usedCounterSum + counterValues[counterIndex]
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            counterIndex = counterIndex + 1
            if(counterIndex > counterValues.count - 1) {
                timer.invalidate()
                minutesLabel.text = "0"
                secondsLabel.text = "00"
                counterIndex = 0
                startstopButton.setTitle("START", for: .normal)
                return
            }
            remaining = counterValues[counterIndex] - getTimer() + usedCounterSum
        }
        minutesLabel.text = getMinutesString(timeInt:remaining)
        secondsLabel.text = String(format:"%02i",getSeconds(timeInt:remaining))
        iterationLabel.text = String(counterIndex)
    }
}

