//
//  ContentView.swift
//  BullsAndCows
//
//  Created by jack on 2020/4/30.
//  Copyright © 2020 jack. All rights reserved.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var digitalObject:DigitalViewModel
    
    var body: some View {
        VStack {
            Spacer().frame(height:30)
            HStack{
                ForEach (digitalObject.inputDigitalArray.indices) { index in
                    DigitalTextField(text:self.$digitalObject.inputDigitalArray[index].digitalStr, inFocus: self.$digitalObject.inputDigitalArray[index].inFocus)
                        .frame(width:50, height: 50)
                        .background(Color.pink)
                }
                
            }
            
            List {
                ForEach(Array(digitalObject.resultArray.enumerated()), id:\.1.id) { idx, result in
                    HStack {
                        Text("\(idx + 1).")
                        Spacer()
                        Text("\(result.inputStr)").font(.system(size: 25))
                        Spacer().frame(width:20)
                        Text("\(result.bullCount)🐂\(result.cowCount)🐄").font(.system(size: 25))
                    }.frame(height:30)
                }
                Spacer().frame(height:digitalObject.listSpacerHeight)
            }.offset(y:-digitalObject.listOffset)
            Spacer()
        }.onTapGesture {
            self.digitalObject.hideKeyboard()
        }
        .alert(isPresented: .init(get: {self.digitalObject.status != .InGame}, set: {self.digitalObject.status = $0 ? .Over : .InGame })) {
            Alert(title: Text(alertTitle()), message: Text(alertMessage()), dismissButton: .default(Text("Yes"), action: {
                self.digitalObject.playAgain()
               }))
        }
    }
    
    func alertTitle() -> String {
        switch self.digitalObject.status {
        case .Over:
            return "Game Over"
        case .Win:
            return "Win!!"
        default:
            return ""
        }
    }
    
    func alertMessage() -> String {
        switch self.digitalObject.status {
        case .Over:
            return "The correct Answer is \(self.digitalObject.secretDigitalStr) \r\n Play again?"
        case .Win:
            return "Play again?"
        default:
            return ""
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView().environmentObject(DigitalViewModel(digitalCount: 4))
    }
}
