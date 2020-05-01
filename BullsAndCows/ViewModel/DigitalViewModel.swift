//
//  DigitalViewModel.swift
//  BullsAndCows
//
//  Created by jack on 2020/4/30.
//  Copyright © 2020 jack. All rights reserved.
//

import SwiftUI
import Combine

let MaxRound = 10

class InputDigital:ObservableObject, Identifiable {
    
    let id = UUID()
    @Published var digitalStr:String = ""
    {
        
        didSet {
            guard let next = focusNext else {
                return
            }
            if digitalStr.count == 1 {
                next()
            }
        }
    }
    @Published var inFocus:Bool = false
    {
        willSet {
            objectWillChange.send()
        }
    }
    var digital:Int {
        get {
            return Int(digitalStr) ?? -1
        }
    }
    
    var focusNext:(() -> Void)?
}

class GeussResult: ObservableObject, Identifiable {
    let id = UUID()
    var bullCount:Int = 0
    var cowCount:Int = 0
    var inputStr:String = ""
    init(bullCount:Int, cowCount:Int, inputStr:String) {
        self.bullCount = bullCount
        self.cowCount = cowCount
        self.inputStr = inputStr
    }
}

enum GameStatus {
    case InGame, Win, Over
}

class DigitalViewModel: ObservableObject {
    
    var digitalCount:Int
    var secretDigitalArray:[Int] = [Int]()
    
    var keyboardHeight:CGFloat = 0.0
    
    @Published var inputDigitalArray:[InputDigital] = [InputDigital]()
    @Published var resultArray:[GeussResult] = [GeussResult]()
    @Published var status: GameStatus = .InGame
    @Published var listOffset:CGFloat = 0.0
    var listSpacerHeight:CGFloat {
        get {
            if listOffset == 0.0 {
                return 0.0
            } else {
                return listOffset + keyboardHeight
            }
        }
    }
    
    var secretDigitalStr: String {
        get {
            return secretDigitalArray.map{ String($0) }.reduce("", +)
        }
    }
    
    init(digitalCount:Int = 4) {
        self.digitalCount = digitalCount
        createNewSecretDigitalArray()
        createInputDigital()
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyBoardDidShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func playAgain() {
        createNewSecretDigitalArray()
        createInputDigital()
        resultArray = [GeussResult]()
        self.keyboardHeight = 0
        self.listOffset = 0
    }
    
    func createInputDigital() {
        inputDigitalArray = Array(repeating: InputDigital(), count: digitalCount)
        for index in 0..<digitalCount {
            let inputDigital = InputDigital()
            inputDigital.focusNext = { [weak self] in
                guard let strongSelf = self else { return }
                let nullStrArray = strongSelf.inputDigitalArray.filter{ $0.digitalStr == "" }
                if nullStrArray.first != nil {
                    nullStrArray.first!.inFocus = true
                } else {
                    strongSelf.calculateResult()
                }
                
                inputDigital.inFocus = false
            }
            inputDigitalArray[index] = inputDigital
        }
    }
    
    func resetInPutDigital() {
        for item in inputDigitalArray {
            item.digitalStr = ""
            item.inFocus = false
        }
    }
    
    func createNewSecretDigitalArray() {
        self.secretDigitalArray = [Int]()
        for _ in 0..<self.digitalCount {
           var randomDigital = Int.random(in: 0...9)
           while self.secretDigitalArray.contains(randomDigital) {
               randomDigital = Int.random(in: 0...9)
           }
           self.secretDigitalArray.append(randomDigital)
       }
    }
    
    func calculateResult() {
        let cowsplusbullsCount = self.inputDigitalArray.filter{ self.secretDigitalArray.contains($0.digital)}.count
        let bullsCount = self.inputDigitalArray.indices.filter{ self.secretDigitalArray[$0] == self.inputDigitalArray[$0].digital }.count
        let cowsCount = cowsplusbullsCount - bullsCount
        
        let inputStr = self.inputDigitalArray.map{$0.digitalStr}.reduce(" ",+)
        
        let geussResult = GeussResult(bullCount: bullsCount, cowCount: cowsCount, inputStr: inputStr)
        self.resultArray.append(geussResult)
        resetInPutDigital()
        
        if bullsCount == digitalCount {
            self.status = .Win
        } else if self.resultArray.count == MaxRound {
            self.status = .Over
        }
    }
    
    func hideKeyboard() {
        for item in self.inputDigitalArray {
            item.inFocus = false
        }
    }
    
    @objc func keyBoardDidShow(_ notification:Notification)
    {
        keyboardHeight = (notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as! CGRect).height
        let totalHeight = 210.0 + keyboardHeight + CGFloat(self.resultArray.count) * 30.0
        let window = UIApplication.shared.windows[0]
        let topPadding = window.safeAreaInsets.top
        let bottomPadding = window.safeAreaInsets.bottom
        print("\(topPadding)   \(bottomPadding)")
        let offset = totalHeight - (UIScreen.main.bounds.height - topPadding - bottomPadding)
        print("offset:\(offset)")
        if offset > 0 {
            self.listOffset = offset
        } else {
            self.listOffset = 0.0
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        self.listOffset = 0
    }
    
}
