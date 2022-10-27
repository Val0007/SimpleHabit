//
//  InputView.swift
//  SimpleHabit
//
//  Created by Val V on 18/08/21.
//

import UIKit

class InputView: UIViewController{

    //MARK:PROPERTIES
    let refreshIndicator:UIActivityIndicatorView = {
        let i = UIActivityIndicatorView()
        i.color  = Colors.buttonGreen
        i.hidesWhenStopped = true
        i.backgroundColor = .gray
        return i
    }()
    
    lazy var refreshView:UIView = {
        let view  = UIView()
        view.addSubview(refreshIndicator)
        refreshIndicator.center(inView: view)
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view.backgroundColor = .gray
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let container:UIView = {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 10
        return container
    }()
    
    private let titleHeader:UILabel = {
        let label = UILabel()
        label.font = Fonts().mediumFont
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let habitName:UITextField = {
        let tf = UITextField()
        tf.font = Fonts().baseFont
        tf.backgroundColor = .systemGray6
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return tf
    }()
    
    private let habitLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Habit Name"
        label.textColor = .black
        return label
    }()
    
    private let timeLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Choose Time(min)"
        label.textColor = .black
        return label
    }()
    
    private let freqLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Choose Frequency(no of times in 7 days)"
        label.textColor = .black
        return label
    }()
    
    private let addButton:UIButton = {
        let button = UIButton()
        button.setTitle("Add", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = Colors.startingGreen
        button.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        return button
    }()
    
    
    
    
    private lazy var habitLabelConstraint = habitLabel.centerYAnchor.constraint(equalTo: habitName.centerYAnchor, constant: 0)
    
    private let bottomLine:UIView = {
        let view = UIView()
        view.backgroundColor = Colors.lightBlue
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()

    private var segmentedPicker:SegmentedView = SegmentedView()
    private var frequencyPicker:SegmentedView = SegmentedView()
    
    private var chosenTime:Int?
    private var chosenFrequency :Int?
    
     var completion:((Habit?)->())?
    
    var isEdit:Bool?
    var editCompletion:((Habit?)->())?
    var habit:Habit?
    
    
    //MARK:LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedPicker.type = .timer
        frequencyPicker.type = .frequency
        makeUI()
        habitName.delegate = self
        segmentedPicker.delegate = self
        frequencyPicker.delegate2 = self
    
    }
    
    override func viewDidLayoutSubviews() {
        if isEdit != nil{
            if let habit = habit{
                print("YESssssss")
                moveBackGround(habit: habit)
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isEdit != nil{
            if let habit = habit{
                editHabit(habit: habit)
            }
        }

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

          let touch = touches.first
          guard let location = touch?.location(in: self.view) else { return }
          if !container.frame.contains(location) {
              print("Tapped outside the view")
              dismiss(animated: true, completion: nil)
          } else {
              print("Tapped inside the view")
              habitName.resignFirstResponder()
          }
    }
    
    
    
    
    //MARK:SELECTORS
    @objc private func handleAdd(){
        guard let name = habitName.text ,!name.isEmpty else {return}
        guard let time = chosenTime else {return}
        guard let freq  = chosenFrequency else {return}
        if isEdit != nil {
            habit!.frequency = freq
            habit!.time = time
            habit!.name = name
            
            if let completion = editCompletion {
                
                DispatchQueue.main.async {
                    self.refreshView.isHidden = false
                    self.refreshIndicator.startAnimating()
                }
                
                DatabaseServices.shared.editHabit(habit: habit!) {[weak self] (bool) in
                    guard let self  = self else {return}
                    if bool{
                        DispatchQueue.main.async {
                            self.refreshView.isHidden = true
                            self.refreshIndicator.stopAnimating()
                            completion(self.habit!)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.refreshView.isHidden = true
                            self.refreshIndicator.stopAnimating()
                            completion(nil)
                            self.dismiss(animated: true, completion: nil)
                        }

                    }
                }

            }
            
        }
        else{
            let id  = UUID().uuidString
            let habit = Habit(id:id,name: name, time: time,frequency: freq)
            
            DispatchQueue.main.async {
                self.refreshView.isHidden = false
                self.refreshIndicator.startAnimating()
            }
            
            DatabaseServices.shared.saveHabit(habitToBeSet: habit){[weak self] bool in
                if bool{
                    if let completion = self?.completion {
                        DispatchQueue.main.async {
                            self?.refreshView.isHidden = true
                            self?.refreshIndicator.stopAnimating()
                            completion(habit)
                            self?.dismiss(animated: true, completion: nil)
                        }

                    }

                }
                else{
                    guard let completion = self?.completion else {return}
                    DispatchQueue.main.async {
                        self?.refreshView.isHidden = true
                        self?.refreshIndicator.stopAnimating()
                        completion(nil)
                        self?.dismiss(animated: true, completion: nil)

                    }
                }
                
            }
        }

        
    }
    
    //MARK:HELPERS
    private func makeUI(){
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.addSubview(container)
        container.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7).isActive = true
        container.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        container.center(inView: view)
        
        container.addSubview(titleHeader)
        titleHeader.anchor(top:container.topAnchor,paddingTop: 10)
        titleHeader.centerX(inView: container)
        
        container.addSubview(habitName)
        habitName.anchor(top:titleHeader.bottomAnchor,left: container.leftAnchor,right: container.rightAnchor,paddingTop: 40,paddingLeft: 10,paddingRight: 10)

        
        container.addSubview(bottomLine)
        bottomLine.anchor(top:habitName.bottomAnchor,left: container.leftAnchor,right: container.rightAnchor,paddingTop: 0,paddingLeft: 10,paddingRight: 10)
        
        container.addSubview(habitLabel)
        habitLabel.anchor(left:habitName.leftAnchor)
        
        habitLabelConstraint.isActive = true


        container.addSubview(segmentedPicker)
        segmentedPicker.anchor(top:habitName.bottomAnchor,left: container.leftAnchor,right: container.rightAnchor,paddingTop: 60,paddingLeft: 10,paddingRight: 10,height: 80)
        container.addSubview(timeLabel)
        timeLabel.anchor(left:segmentedPicker.leftAnchor,bottom: segmentedPicker.topAnchor)
        
        container.addSubview(frequencyPicker)
        frequencyPicker.anchor(top:segmentedPicker.bottomAnchor,left: container.leftAnchor,right: container.rightAnchor,paddingTop: 40,paddingLeft: 10,paddingRight: 10,height: 80)
        container.addSubview(freqLabel)
        freqLabel.anchor(left:frequencyPicker.leftAnchor,bottom: frequencyPicker.topAnchor)

        
        
        container.addSubview(addButton)
        addButton.anchor(left: container.leftAnchor,bottom: container.bottomAnchor,right: container.rightAnchor,paddingLeft: 20,paddingBottom: 15,paddingRight: 20,height: 50)
        
        view.addSubview(refreshView)
        refreshView.center(inView: view)
        refreshView.isHidden = true
        
        populateUI()
    }
    
    private  func populateUI(){
        
        titleHeader.text = "Create a new Habit"
        
        
    }
    
    func editHabit(habit:Habit){
        titleHeader.text = "Edit Habit"
        habitName.text = habit.name
        moveLabelUp()
        addButton.setTitle("Save", for: .normal)

    }
    
    func moveBackGround(habit:Habit){
        segmentedPicker.moveButtonOnEdit(segmentType: .timer,number: habit.time)
        frequencyPicker.moveButtonOnEdit(segmentType: .frequency,number: habit.frequency)
    }

}


extension InputView:UITextFieldDelegate{
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if habitName.text == "" {
            moveLabelDown()
        }
        else{
            moveLabelUp()
        }
    }

    private  func moveLabelUp(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self  = self else {return}
                self.habitLabelConstraint.isActive = false
                self.habitLabelConstraint.constant = -30
                self.habitLabelConstraint.isActive = true
                self.view.layoutIfNeeded()

            }
        }
    }
    
    private  func moveLabelDown(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {[weak self] in
                guard let self  = self else {return}
                self.habitLabelConstraint.isActive = false
                self.habitLabelConstraint.constant = 0
                self.habitLabelConstraint.isActive = true
                self.view.layoutIfNeeded()

            }
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        habitName.resignFirstResponder()
    }
}


extension InputView:ChooseTime{
    internal func chosenTime(time: Int) {
        switch time {
        case 0:
            chosenTime = 10
        case 1:
            chosenTime = 15
        case 2:
            chosenTime = 30
        case 3:
            chosenTime = 60
        default:
            chosenTime = 10
        }
        
}
    

}

extension InputView:ChooseFreq{
    func chosenFreq(freq: Int) {
        switch freq {
        case 0:
            print("7")
            chosenFrequency = 1 //daily
        case 1:
            print("2")
            chosenFrequency = 6 //twice
        case 2:
            print("3")
            chosenFrequency = 3 //thrice
        case 3:
            print("1")
            chosenFrequency = 7 //weekly
        default:
            print("DEF")
            
        //if problem change by -1.
        }
    }
}
