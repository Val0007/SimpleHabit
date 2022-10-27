//
//  SegmentedView.swift
//  SimpleHabit
//
//  Created by Val V on 19/08/21.
//

import UIKit



enum TimeOptions:Int,CaseIterable {
    case TEN = 0
    case FIFTEEN = 1
    case THIRTY = 2
    case SIXTY = 3
    
}

enum FrequencyOptions:Int,CaseIterable{
    case daily = 0
    case twice = 1
    case thirce = 2
    case weekly  = 3
}

enum SegmentType{
    case timer
    case frequency
}

protocol ChooseTime:AnyObject{
    func chosenTime(time:Int)
}

protocol ChooseFreq:AnyObject {
    func chosenFreq(freq:Int)
}

class SegmentedView: UIView {

   private let container = UIView()
    var moveItem:Int?
    
    weak var delegate:ChooseTime?
    weak var delegate2:ChooseFreq?
    
    var type:SegmentType!
    
   private var initialOption = 0
    
    private let backGroundColorView:UIView = {
        let view  = UIView()
        view.backgroundColor  = Colors.lightBlue
        return view
    }()
    
    private var previousButton : UIButton?
    
    
      
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        makeUI()  //to get frame width and height we need layout subViews
    }
    
    private func makeUI(){
        
        makeBackGroundColorView()
        
        let stack:UIStackView = {
            let stack  = UIStackView()
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing  = 10
            return stack
            
        }()
        
        if type == .timer{
            for bt in TimeOptions.allCases{
                let button = UIButton()
                button.setTitle(returnButtonNames(option: bt), for: .normal)
                button.setTitleColor(.black, for: .normal)
                button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
                button.tag = bt.rawValue
                stack.addArrangedSubview(button)
                previousButton = button
            }
        }
        else{
            for bt in FrequencyOptions.allCases{
                let button = UIButton()
                button.setTitle(returnButtonNamesForFreq(option: bt), for: .normal)
                button.setTitleColor(.black, for: .normal)
                button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
                button.tag = bt.rawValue
                stack.addArrangedSubview(button)
                previousButton = button
            }
        }
        

        
        addSubview(container)
        container.addConstraintsToFillView(self)
        container.addSubview(stack)
        stack.anchor(top: container.topAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, right: container.rightAnchor)
        
        if type == .timer{
            delegate?.chosenTime(time: initialOption)
        }
        else{
            delegate2?.chosenFreq(freq: initialOption)
        }
        
    }
    
    
    @objc private func handleTap(sender:UIButton){
        
        switch sender.tag {
        case 0:

            moveBackground(button: sender,position: nil)
            if type == .timer{
                delegate?.chosenTime(time: sender.tag)
            }
            else{
                delegate2?.chosenFreq(freq: sender.tag)
            }
        case 1:
            moveBackground(button: sender,position: nil)
            if type == .timer{
                delegate?.chosenTime(time: sender.tag)
            }
            else{
                delegate2?.chosenFreq(freq: sender.tag)
            }
        case 2:
            moveBackground(button: sender,position: nil)
            if type == .timer{
                delegate?.chosenTime(time: sender.tag)
            }
            else{
                delegate2?.chosenFreq(freq: sender.tag)
            }
        case 3:
            moveBackground(button: sender,position: nil)
            if type == .timer{
                delegate?.chosenTime(time: sender.tag)
            }
            else{
                delegate2?.chosenFreq(freq: sender.tag)
            }
        default:
            print("YES")
        }
        
        
    }
    
    private func makeBackGroundColorView(){
        
        let selectorWidth:CGFloat!
        if type == .timer{
             selectorWidth = frame.width/CGFloat(TimeOptions.allCases.count)

        }
        else{
            selectorWidth = frame.width/CGFloat(FrequencyOptions.allCases.count)
        }
        backGroundColorView.frame = CGRect(x: 0, y: 25, width: selectorWidth, height: 30)
        backGroundColorView.layer.cornerRadius = 10
        addSubview(backGroundColorView)
    }
    
    private func moveBackground(button:UIButton?,position:Int?){
        let selectorPosition:CGFloat!
        if let position = position {
            if type == .timer{
                selectorPosition = frame.width/CGFloat(TimeOptions.allCases.count) * CGFloat(position)
                delegate?.chosenTime(time: position)
            }
            else{
                selectorPosition = frame.width/CGFloat(FrequencyOptions.allCases.count) * CGFloat(position)
                delegate2?.chosenFreq(freq: position)
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self  = self else {return}
                    self.backGroundColorView.frame.origin.x = selectorPosition
                    self.layoutIfNeeded()
            }
            return
        }
        if type == .timer{
            selectorPosition = frame.width/CGFloat(TimeOptions.allCases.count) * CGFloat(button!.tag)
        }
        else{
            selectorPosition = frame.width/CGFloat(FrequencyOptions.allCases.count) * CGFloat(button!.tag)
        }
        DispatchQueue.main.async { [weak self] in
            guard let self  = self else {return}
            UIView.animate(withDuration: 0.3) {
                self.backGroundColorView.frame.origin.x = selectorPosition
                self.layoutIfNeeded()
            }

        }
    }
    
    func moveButtonOnEdit(segmentType:SegmentType,number:Int){
        let position = returnPosition(num: number, segmentType: segmentType)
        print("The position is \(position)")
        moveBackground(button: nil, position: position)
        
    }
    
    func returnButtonNames(option:TimeOptions) ->String {
        switch option{
        case .TEN:return "10"
        case .FIFTEEN:return "15"
        case .THIRTY:return "30"
        case .SIXTY:return "60"
        }
    }
    
    func returnButtonNamesForFreq(option:FrequencyOptions) ->String {
        switch option{
        case .daily:return "7"
        case .thirce:return "3"
        case .twice:return "2"
        case .weekly:return "1"
        }
    }
    
    func returnPosition(num:Int,segmentType:SegmentType)->Int{
        if segmentType == .timer{
            switch num {
            case 10:
                return 0
            case 15:
                return 1
            case 30:
                return 2
            case 60:
                return 3
            default:
                return 0
            }
        }
        else{
            switch num {
            case 1:           //freq is 1 = everyday, 2 = every 2 days , 3 = means every 3 days which is 2Times a week
                return 0
            case 2:
                return 2
            case 3:
                return 1
            case 7:
                return 3
            default:
                return 0
            }
        }
    }
    
}
