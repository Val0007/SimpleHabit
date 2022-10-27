//
//  HabitCell.swift
//  SimpleHabit
//
//  Created by Val V on 21/08/21.
//

import UIKit

protocol HabitCellDelegate:AnyObject {
    func startTimer(habit:Habit,cell:HabitCell)
    func editHabit(habit:Habit,cell:HabitCell)
}

class HabitCell: UITableViewCell {

     var isExpanded:Bool?{
        didSet{
            makeUI()
        }
    }
    
    weak var delegate:HabitCellDelegate?
    var afterEditHabit:((Habit)->())?
    
    private let titleLabel:UILabel = {
        let label = UILabel()
        label.font = Fonts().mediumFont
        label.textColor = .black
        return label
    }()

    private let streakCountLabel:UILabel = {
        let label = UILabel()
        label.font = Fonts().mediumFont
        label.textAlignment = .center
        label.textColor = .black
        label.layer.borderWidth = 0.7
        label.layer.borderColor = UIColor.separator.cgColor
        label.layer.cornerRadius = 8
        return label
    }()
    
    private let timeCountLabel:UILabel = {
        let label = UILabel()
        label.font = Fonts().mediumFont
        label.textAlignment = .center
        label.textColor = .black
        label.layer.borderWidth = 0.7
        label.layer.borderColor = UIColor.separator.cgColor
        label.layer.cornerRadius = 8
        return label
    }()
    
    private let nextDateLabel:UILabel = {
        let label = UILabel()
        label.font = Fonts().mediumFont
        label.textAlignment = .center
        label.textColor = .black
        label.layer.borderWidth = 0.7
        label.layer.borderColor = UIColor.separator.cgColor
        label.layer.cornerRadius = 8
        return label
    }()
    
    
    private  var streakCountViewLabel = UIHelper.generateLabelForCell(name: "Streak")
    
    private  lazy var editButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .secondarySystemBackground
        button.layer.borderWidth = 0.7
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        return button
    }()
    
    private  lazy var startButton:UIButton = {
        let button = UIButton()
        button.setTitle("Start Timer", for: .normal)
        button.backgroundColor = Colors.lightBlue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleStart), for: .touchUpInside)
        return button
    }()
    
    private let container = UIView()
    private let container2 = UIView()
    
    var habit:Habit?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK:SELECTORS
  @objc private func handleStart(){
    guard let habit = habit else {return}
    if let nextDate = habit.nextDate {
        let req = DateCalculator.canStartTimer(date: nextDate)
        if req{
            delegate?.startTimer(habit: habit,cell: self)
        }
        else{
            return
        }
    }
    else{
        delegate?.startTimer(habit: habit,cell: self)
    }
    
    }
    
    @objc private func handleEdit(){
        delegate?.editHabit(habit: habit!,cell: self)
    }
    
    
    
    
    
    //MARK:HELPERS
    private func makeUI(){
        
        guard let expanded = isExpanded else {return}
        print("\(habit?.name) is Expanded -  \(expanded)")
        if expanded{
            container.removeFromSuperview()
            container.subviews.forEach({ $0.removeFromSuperview() })
    
            makeExpandedUI()
            return
        }
        container2.removeFromSuperview()
        container2.subviews.forEach({ $0.removeFromSuperview() })
        
        backgroundColor = Colors.baseColor
        addSubview(container)
        container.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10)
        container.backgroundColor = .white
        container.layer.cornerRadius = 10
        
        makeStackView()

        titleLabel.text = habit?.name
        streakCountLabel.text = String(habit!.streak)
        changeBackGround()
    }
    
    
    private  func makeStackView(){
        streakCountLabel.translatesAutoresizingMaskIntoConstraints = false
        streakCountViewLabel.translatesAutoresizingMaskIntoConstraints = false
        let streakStack = UIStackView(arrangedSubviews: [streakCountViewLabel,streakCountLabel])
        streakStack.translatesAutoresizingMaskIntoConstraints = false
        streakStack.axis = .vertical
        streakStack.distribution = .fill
        streakStack.spacing = 5
        streakCountLabel.heightAnchor.constraint(equalTo: streakStack.heightAnchor, multiplier: 0.7).isActive = true

        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [titleLabel,streakStack])
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 5
        titleLabel.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 0.8).isActive = true

        
        container.addSubview(stack)
        stack.anchor(top:container.topAnchor,left: container.leftAnchor,bottom: container.bottomAnchor,right: container.rightAnchor,paddingTop: 10,paddingLeft: 10,paddingBottom: 10,paddingRight: 10)
        
    }
    
    private  func makeExpandedUI(){
        container2.removeFromSuperview()
        container2.subviews.forEach({ $0.removeFromSuperview() })
      
        addSubview(container2)
        container2.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10)
        container2.backgroundColor = .white
        container2.layer.cornerRadius = 10
        
        container2.addSubview(titleLabel)
        container2.addSubview(editButton)
        
        titleLabel.anchor(top:container2.topAnchor,left: container2.leftAnchor,right: editButton.leftAnchor,paddingTop: 10,paddingLeft: 5,paddingRight: 5)
        editButton.anchor(top:container2.topAnchor,right: container2.rightAnchor,paddingTop: 10,paddingRight: 5,width: 25, height: 25)
        

        makeExpandedViewStack()
        upDateValue()
        
        
    }
    
    private  func makeExpandedViewStack(){


        let finalStack = UIHelper.makeLabelStackView(timeLabel: timeCountLabel, streakLabel: streakCountLabel, nextLabel: nextDateLabel)
        container2.addSubview(finalStack)
        finalStack.anchor(top: titleLabel.bottomAnchor, left: container2.leftAnchor,right: container2.rightAnchor, paddingTop: 20, paddingLeft: 5,paddingRight: 5,height: 80)
        
        container2.addSubview(startButton)
        startButton.anchor(top: finalStack.bottomAnchor, left: container2.leftAnchor,right: container2.rightAnchor, paddingTop: 20, paddingLeft: 40,paddingRight: 40,height: 40)
        self.changeBackGround()
        
    }
    
    func changeBackGround(){
        guard let habit = habit else {return}
        if let nextDate = habit.nextDate{
            let tv = DateCalculator.returnTimeInterval(date: nextDate)
            if tv>0 && tv<86400{
                cellBackGround(green: false)
            }
            
            else if tv<0{
                cellBackGround(green: true)
            }
            else{
                return
            }
        }
        else{
            container.layer.borderWidth = 0
            container2.layer.borderWidth = 0
        }
    }
       
    func checkTimeIsThere(){
        guard let habit = habit else {return}
        if let nextDate = habit.nextDate{
            let tv = DateCalculator.returnTimeInterval(date: nextDate)
            if tv>0 && tv<86400{
                nextDateLabel.font = UIFont.systemFont(ofSize: 14)
                nextDateLabel.text = "Due Today"
                buttonBackGround()
            }
            else if tv>86400{
                print("Yes")
                self.habit!.streak = 0
                self.habit!.nextDate = nil
                DatabaseServices.shared.editHabit(habit: self.habit!) { bool in
                    if bool{
                        self.afterEditHabit!(self.habit!)
                    }
                }
                streakCountLabel.text = String(self.habit!.streak)
                calcNextTime()
                buttonBackGround()
            }
            
            else if tv<0{
                calcNextTime()
                buttonBackGround()
            }
            else{
                return
            }
        }
        else{
            calcNextTime()
            buttonBackGround()
        }
    }
    
      func upDateValue(){
        guard let habit = habit else {return}
        DispatchQueue.main.async {
            self.titleLabel.text = habit.name
            self.streakCountLabel.text = String(habit.streak)
            self.timeCountLabel.text = String(habit.time)
            self.checkTimeIsThere()
            self.changeBackGround()
        }

        
    }
    
    private func calcNextTime(){
        guard let habit = habit else {return}
        if let nextDate = habit.nextDate{
            let tv = DateCalculator.returnTimeInterval(date: nextDate)
            nextDateLabel.text = tv.stringTime
            nextDateLabel.numberOfLines = 0
            nextDateLabel.font = UIFont.systemFont(ofSize: 14)
        }
        else{
            nextDateLabel.font = UIFont.systemFont(ofSize: 12)
            nextDateLabel.numberOfLines = 0
            nextDateLabel.text = "Start Habit to show the next time"
        }
      
    }
    
    private func cellBackGround(green:Bool){
        if green{
            
            if let expanded = isExpanded{
                if expanded{
                    container2.layer.borderWidth = 1.0
                    container2.layer.borderColor = Colors.endingGreen.cgColor
                }
                else{
                    container.layer.borderWidth = 1.0
                    container.layer.borderColor = Colors.endingGreen.cgColor
                }
            }
            else{
                container.layer.borderWidth = 1.0
                container.layer.borderColor = Colors.endingGreen.cgColor

            }
        }
        else{
            if let expanded = isExpanded{
                if expanded{
                    container2.layer.borderWidth = 1.0
                    container2.layer.borderColor = UIColor.red.cgColor
                }
                else{
                    container.layer.borderWidth = 1.0
                    container.layer.borderColor = UIColor.red.cgColor
                }
            }
            else{
                container.layer.borderWidth = 1.0
                container.layer.borderColor = UIColor.red.cgColor

            }

        }
    }
    
    private func buttonBackGround(){
        if let nextDate = habit?.nextDate{
            let req = DateCalculator.canStartTimer(date: nextDate)
            if req{
                startButton.backgroundColor = Colors.lightBlue
                startButton.setTitleColor(.white, for: .normal)
                return
            }
            else{
                startButton.backgroundColor = UIColor.secondarySystemFill
                startButton.setTitleColor(.black, for: .normal)
            }
        }
        else{
            startButton.backgroundColor = Colors.lightBlue
            startButton.setTitleColor(.white, for: .normal)
        }
    }
    

    
}

extension TimeInterval {

    //abs for positive values
    
    private var minutes: Int {
        return (abs(Int(self)) / 60 ) % 60  //126min%60 = 6 min so that hours will give 2 = 2hrs 6min
                                       //33 min = 0 hrs, 2000/60 = 33 ,33%60 = 33min
    }

    private var hours: Int {
        return abs(Int(self)) / 3600
    }
    
    private var days:Int{
        if hours > 24 {
            return hours/24
        }
        else{
            return 0
        }
    }

    var stringTime: String {
        
        if days != 0{
            let hrs = hours % 24
            return "\(days)Days \(hrs)hrs"
        }
        else if hours != 0 {
            return "\(hours)hrs \(minutes)min"
        }
        else if minutes != 0 {
            return "\(minutes)min"

        }
        else{
            return "in a min"
        }
        
    }
}
