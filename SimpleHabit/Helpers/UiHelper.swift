//
//  UiHelper.swift
//  SimpleHabit
//
//  Created by Val V on 27/08/21.
//

import Foundation
import UIKit

struct UIHelper{
    
    static func generateLabelForCell(name:String) -> UILabel {
        let label = UILabel()
        label.text = name
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }
    
    static func makeLabelStackView(timeLabel:UILabel,streakLabel:UILabel,nextLabel:UILabel) ->UIStackView {
        
        
        let streakCountViewLabel = generateLabelForCell(name: "Streak")
        let timeViewLabel = generateLabelForCell(name: "Time")
        let nextViewLabel  = generateLabelForCell(name: "Next In")
        
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        streakCountViewLabel.translatesAutoresizingMaskIntoConstraints = false
        let streakStack = UIStackView(arrangedSubviews: [streakCountViewLabel,streakLabel])
        streakStack.translatesAutoresizingMaskIntoConstraints = false
        streakStack.axis = .vertical
        streakStack.distribution = .fill
        streakStack.spacing = 5
        streakLabel.heightAnchor.constraint(equalTo: streakStack.heightAnchor, multiplier: 0.7).isActive = true
        
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeViewLabel.translatesAutoresizingMaskIntoConstraints = false
        let timeStack = UIStackView(arrangedSubviews: [timeViewLabel,timeLabel])
        timeStack.translatesAutoresizingMaskIntoConstraints = false
        timeStack.axis = .vertical
        timeStack.distribution = .fill
        timeStack.spacing = 5
        timeLabel.heightAnchor.constraint(equalTo: timeStack.heightAnchor, multiplier: 0.7).isActive = true
        
        nextLabel.translatesAutoresizingMaskIntoConstraints = false
        nextViewLabel.translatesAutoresizingMaskIntoConstraints = false
        let nextStack = UIStackView(arrangedSubviews: [nextViewLabel,nextLabel])
        nextStack.translatesAutoresizingMaskIntoConstraints = false
        nextStack.axis = .vertical
        nextStack.distribution = .fill
        nextStack.spacing = 5
        nextLabel.heightAnchor.constraint(equalTo: nextStack.heightAnchor, multiplier: 0.7).isActive = true
        
        
        let finalStack = UIStackView(arrangedSubviews: [timeStack,streakStack,nextStack])
        finalStack.translatesAutoresizingMaskIntoConstraints = false
        finalStack.distribution = .fillEqually
        finalStack.axis = .horizontal
        finalStack.spacing = 5
        return finalStack
        
    }
    
}
