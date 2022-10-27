//
//  Fonts.swift
//  SimpleHabit
//
//  Created by Val V on 18/08/21.
//

import Foundation
import UIKit

struct Fonts{
    
    var timerFont:UIFont{
        if let font = UIFont.init(name: "AvenirNext-Regular", size: 35){
            return font
        }
        return UIFont.systemFont(ofSize: 30)
    }
    
    var baseFont:UIFont{
        if let font = UIFont.init(name: "AvenirNext-Regular", size: 23){
            return font
        }
        return UIFont.systemFont(ofSize: 18)
    }
    
    var titleFont:UIFont{
        if let font = UIFont.init(name: "AvenirNext-Bold", size: 28){
            return font
        }
        return UIFont.systemFont(ofSize: 28)
    }
    
    var mediumFont:UIFont{
        if let font = UIFont.init(name: "AvenirNext-medium", size: 24){
            return font
        }
        return UIFont.systemFont(ofSize: 22)
    }
    
}
