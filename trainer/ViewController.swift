//
//  ViewController.swift
//  trainer
//
//  Created by Vladislav Matus on 19/01/2019.
//  Copyright © 2019 Vladislav Matus. All rights reserved.
//

import UIKit
import AudioToolbox
import Foundation

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var iterationLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var startstopButton: UIButton!
    @IBOutlet weak var startBreathTimeValue: UITextField!
    @IBOutlet weak var decreaseBreathValue: UITextField!
    @IBOutlet weak var holdTimeValue: UITextField!
    @IBOutlet weak var increaseHoldValue: UITextField!
    @IBOutlet weak var exerciseType: UISegmentedControl!
    @IBOutlet weak var decreaseBreathController: UIStackView!
    @IBOutlet weak var increaseHoldController: UIStackView!
    @IBOutlet weak var settingsView: UIStackView!
    
    var isOn = false
    var timer = Timer()
    var counterValues = [62000,1000]
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
        //+1000 is correction for seconds
        if ((timeInt + 1000) / 60000 > 9) {
            return "#"
        }
        return String((timeInt + 1000) / 60000)
    }
    func getSeconds(timeInt:Int) -> Int {
        let seconds = Int(ceil(Double(timeInt % 60000)/1000.0))
        if(seconds == 60) {
            return 0
        }
        return seconds
    }
    
    func resetAll() {
        timer.invalidate()
        minutesLabel.text = getMinutesString(timeInt:counterValues[0])
        secondsLabel.text = String(format:"%02i",getSeconds(timeInt:counterValues[0]))
        iterationLabel.text = ""
        startTimestamp = Int64(0)
        stopTimestamp = Int64(0)
        counterIndex = 0
        usedCounterSum = 0
        isOn = false
        startstopButton.setTitle("START", for: .normal)
        setExerciseType()
        settingsView.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        recalculateCounterValues()
        resetAll()
    }

    @IBAction func buttonClicked(_ sender: UIButton) {
        isOn = !isOn
        if isOn {
            startTimestamp += Date().toMillis() - stopTimestamp
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
            startstopButton.setTitle("STOP", for: .normal)
            settingsView.isHidden = true
        }
        else {
            stopTimestamp = Date().toMillis()
            startstopButton.setTitle("START", for: .normal)
            timer.invalidate()
            settingsView.isHidden = false
        }
    }
    
    func timeStringToMs(tS:String) -> Int {
        //TODO check incomming value
        let timeArr = tS.components(separatedBy: ":")
        let time = (Int(timeArr[0])! * 60 + Int(timeArr[1])!)*1000
        return time //TODO write the body
    }
    
    func recalculateCounterValues() {
        let iterations = 8 //TODO make dynamic
        counterValues = Array(repeating: 0, count: iterations * 2)
        let sBInt = timeStringToMs(tS: String(startBreathTimeValue.text!))
        let dBInt = timeStringToMs(tS: String(decreaseBreathValue.text!))
        let hInt = timeStringToMs(tS: String(holdTimeValue.text!))
        let iHInt = timeStringToMs(tS: String(increaseHoldValue.text!))
        if(exerciseType.selectedSegmentIndex == 0) {
            for i in 0...iterations - 1 {
                counterValues[2*i] = sBInt - i * dBInt
                counterValues[2*i+1] = hInt
            }
        }
        else {
            for i in 0...iterations - 1 {
                counterValues[2*i] = sBInt
                counterValues[2*i+1] = hInt + i * iHInt
            }
        }
    }
    
    @IBAction func valueEdited(_ sender: UITextField) {
        recalculateCounterValues()
        resetAll()
    }
    
    @objc func UpdateTimer() {
        var remaining = counterValues[counterIndex] - getTimer() + usedCounterSum
        if (remaining <= 0) {
            usedCounterSum = usedCounterSum + counterValues[counterIndex]
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            counterIndex = counterIndex + 1
            if(counterIndex > counterValues.count - 1) {
                resetAll()
                return
            }
            remaining = counterValues[counterIndex] - getTimer() + usedCounterSum
        }
        minutesLabel.text = getMinutesString(timeInt:remaining)
        secondsLabel.text = String(format:"%02i",getSeconds(timeInt:remaining))
        if (counterIndex % 2 == 0) {
            iterationLabel.text = "BREATHE"
        }
        else {
            iterationLabel.text = "HOLD"
        }
    }
    
    func setExerciseType() {
        if(exerciseType.selectedSegmentIndex == 0) {
            decreaseBreathController.isHidden = false
            increaseHoldController.isHidden = true
        }
        else {
            decreaseBreathController.isHidden = true
            increaseHoldController.isHidden = false
        }
    }
    
    @IBAction func exerciseTypeChnged(_ sender: Any) {
        setExerciseType()
    }
}

