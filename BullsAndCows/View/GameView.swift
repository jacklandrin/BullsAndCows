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
        Image("background").resizable().edgesIgnoringSafeArea(.all).blur(radius: 4).overlay(
        VStack(spacing:0) {
            Spacer().frame(height:30)
            
            Text("Bulls & Cows")
                .font(.system(size: 40))
                .shadow(radius: 5)
                .foregroundColor(Color.white)
            
            HStack{
                Spacer()
                ForEach (digitalObject.inputDigitalArray.indices) { index in
                    DigitalTextField(text:self.$digitalObject.inputDigitalArray[index].digitalStr, inFocus: self.$digitalObject.inputDigitalArray[index].inFocus)
                        .frame(width:50, height: 50)
                        .background(Color(red: 0, green: 153 / 255, blue: 0).opacity(0.5))
                }
                Spacer()
            }
            .zIndex(3)
                .frame(height:70)
                .padding(.bottom, 10)
            
            List {
                ForEach(Array(digitalObject.resultArray.enumerated()), id:\.1.id) { idx, result in
                    HStack {
                        Text("\(idx + 1).")
                            .foregroundColor(Color.white)
                        Spacer()
                        Text("\(result.inputStr)")
                            .font(.system(size: 25))
                            .foregroundColor(Color.white)
                        Spacer().frame(width:20)
                        Text("\(result.bullCount)🐂\(result.cowCount)🐄")
                            .font(.system(size: 25))
                            .foregroundColor(Color.white)
                    }.listRowBackground(Color.green.opacity(0.4))
                    .frame(height:30)
                        
                }
                if #available(iOS 14, *) {
                    
                } else {
                    Spacer()
                        .frame(height:digitalObject.listSpacerHeight)
                }
                
            }.offset(y:-digitalObject.listOffset)// for iOS 13
                .animation(.default)
                .clipped()
                .background(Color.clear)
            Spacer()
        }.onTapGesture {
            if #available(iOS 14, *) {
                
            } else {
                self.digitalObject.hideKeyboard()
                self.digitalObject.objectWillChange.send()
            }
            
        }
        .alert(isPresented: .init(get: {self.digitalObject.status != .InGame}, set: {self.digitalObject.status = $0 ? .Over : .InGame })) {
            Alert(title: Text(alertTitle()), message: Text(alertMessage()), dismissButton: .default(Text("Yes"), action: {
                self.digitalObject.playAgain()
               }))
        }
        .onAppear{
            UITableView.appearance().separatorColor = .clear
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
        })
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
        Group {
            GameView().environmentObject(DigitalViewModel(digitalCount: 4))
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            .previewDisplayName("iPhone X")
            
            GameView().environmentObject(DigitalViewModel(digitalCount: 4))
                       .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (3rd generation)"))
                       .previewDisplayName("iPad Pro")
        }
    }
}
