//
//  CustomTextField.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 19/12/22.
//
import UIKit
import Foundation

class CustomTextField:UITextField {
    
       init(placeholder: String) {
        super.init(frame: .zero)
           
        let spacer = UIView()
           spacer.setDimensions(height: 50, width: 8)
           leftView = spacer
           leftViewMode = .always
        attributedPlaceholder = NSAttributedString(string: placeholder,attributes: [.foregroundColor:UIColor(white: 0, alpha: 0.7)])
        textColor = .black
        backgroundColor = UIColor(white: 1, alpha: 1)
        borderStyle = .roundedRect
        font = UIFont.systemFont(ofSize: 14)
        keyboardAppearance = .default
        tintColor = .black
        autocorrectionType = .no
        autocapitalizationType = .words
        spellCheckingType = .no
        setHeight(50)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
