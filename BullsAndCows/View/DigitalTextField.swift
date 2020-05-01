//
//  DigitalTextField.swift
//  BullsAndCows
//
//  Created by jack on 2020/4/30.
//  Copyright © 2020 jack. All rights reserved.
//

import SwiftUI

struct DigitalTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var inFocus:Bool
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<DigitalTextField>) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.font = UIFont.boldSystemFont(ofSize: 30)
        textField.textColor = UIColor.yellow//(red: 0, green: 153/255, blue: 255/255, alpha: 1)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context:
        UIViewRepresentableContext<DigitalTextField>) {
        uiView.text = text
        
        guard uiView.window != nil else {
            return
        }
        
        if inFocus, !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !inFocus && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: DigitalTextField

        init(_ digitalTextField: DigitalTextField) {
            self.parent = digitalTextField
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.text = ""
            textField.becomeFirstResponder()
            self.parent.inFocus = true
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            if parent.text != textField.text {
                 parent.text = textField.text ?? ""
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.inFocus = false
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let textFieldText = textField.text,
                let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                    return false
            }
            let substringToReplace = textFieldText[rangeOfTextToReplace]
            let count = textFieldText.count - substringToReplace.count + string.count
            return count <= 1
        }
    }
}
