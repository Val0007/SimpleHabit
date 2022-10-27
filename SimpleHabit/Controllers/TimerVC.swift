//
//  TimerVC.swift
//  SimpleHabit
//
//  Created by Val V on 21/08/21.
//

import UIKit

enum ButtonState:String{
    case start = "Start"
    case stop = "Stop"
}

class TimerVC: UIViewController {
    
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
    

    //MARK:PROPERTIES
   private var habit:Habit
    private var seconds:Int
    private var timer = Timer()
    private var starTime:TimeInterval?
    private  var isTimerRunning:Bool = false
    private  var circleLayer:CAShapeLayer!
    private var underCircleLayer = CAShapeLayer()
    private var notificationScheduled  = false
    var completion:(Habit?)->()
    
    private  let titleLabel:UILabel = {
        let label = UILabel()
        label.font = Fonts().titleFont
        label.textColor = .black
        return label
    }()
    
    private let button:UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        button.backgroundColor = Colors.buttonGreen
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let quitButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName:"xmark"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .systemGray4
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    private let timerLabel:UILabel = {
        let label = UILabel()
        label.font = Fonts().timerFont
        label.textColor = .black
        label.textAlignment  = .center
        return label
    }()
    
    
    //MARK:LIFECYCLE
    init(habit:Habit,completion:@escaping(Habit?)->()){
        self.habit = habit
        self.seconds = habit.time * 60
        self.completion = completion
        //self.seconds = 10
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.baseColor
        makeUI()

    }

    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .all  //Or, return .all to "disable" the control center as well
    }
    
    
    
    //MARK:SELECTORS
    @objc func handleButtonTap(){
        if !isTimerRunning && seconds>0{
            startTimer(secondsLeft: Double(seconds),strokePoint: 0)
        }
        else if isTimerRunning{
            showAlert()
        }
        else{
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func handleDismiss(){
        if isTimerRunning{
            showAlert()
        }
        else{
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func showAlert(){
        let refreshAlert = UIAlertController(title: "Stop Timer", message: "You Timer will be dismissed", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {[weak self] (action: UIAlertAction!) in
            guard let self = self else {return}
            refreshAlert.dismiss(animated: true, completion: nil)
            self.isTimerRunning = false
            self.timer.invalidate()
            self.dismiss(animated: true, completion: nil)
            
           }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    refreshAlert.dismiss(animated: true, completion: nil)
           }))

        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    @objc private func willResignActive(){
        if isTimerRunning{
            print("Exited")
            let currentTime = Date()
            let currentSeconds = seconds
            print(currentTime)
            timer.invalidate() // to stop it from running in backGround
            UserDefaults.standard.setValue(currentTime, forKey: "timeLeftTheView")
            UserDefaults.standard.setValue(currentSeconds, forKey: "secondsLeft")
            print(seconds)
        }
        else{
            print("Timer not running")
        }


    }
    

    
    @objc private func didComeBackFromSwiping(){
        if isTimerRunning{
           
            if let timeLeft = UserDefaults.standard.value(forKey: "timeLeftTheView"){
                if var secondsLeft = UserDefaults.standard.value(forKey: "secondsLeft") as? Int{
                    let tL = timeLeft as! Date
                    
                    let secondsPassed  = Date().timeIntervalSince(tL)
                    secondsLeft = secondsLeft - Int(ceil(Double(secondsPassed))) //forced to round up 4.4 to 5
                    print(secondsPassed)
                    print(secondsLeft)//acc to my calc
                    print("Initially when left \(seconds)")
                    //actual time is 2 seconds less since it is allowed to run two seconds in the background
                    //so we stopped the timer
                    
                    if secondsLeft > 0 {
                        seconds = secondsLeft
                        print("Now after my calc \(seconds)")
                        timerLabel.text = getTimeString(time: seconds)
                        let point = getStrokePoint(secondsLeft: seconds)
                        circleLayer.removeAllAnimations()
                        makeCircle(redraw: true, stroke: CGFloat(point))
                        startTimer(secondsLeft: Double(seconds),strokePoint: point)
                        
                    }
                    else{
                        timer.invalidate()
                        seconds = 0
                        timerLabel.text = getTimeString(time: seconds)
                        isTimerRunning = false
                        finishedTimer()
                        changeButtonBackground()

                    }
                    
                }
            }
        }
        print("Came back from Swiping")

    }

    
    //MARK:HELPERS
   private func makeUI(){
        view.addSubview(quitButton)
        quitButton.anchor(top:view.safeAreaLayoutGuide.topAnchor,right: view.safeAreaLayoutGuide.rightAnchor,paddingTop: 15,paddingRight: 15)
    view.addSubview(titleLabel)
    titleLabel.anchor(top:view.safeAreaLayoutGuide.topAnchor,paddingTop: 15)
    titleLabel.centerX(inView: view)
    titleLabel.text = habit.name
    
    view.addSubview(button)
    button.centerX(inView: view)
    button.anchor(left:view.safeAreaLayoutGuide.leftAnchor,bottom:view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor,paddingLeft: 40,paddingBottom: 50,paddingRight: 40,height: 60)
    
    
    view.addSubview(timerLabel)
    timerLabel.centerX(inView: view)
    timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
    timerLabel.text = "\(habit.time):00"
    
    detectBackground()
    
    makeCircle(redraw: false, stroke: 0.0)
    
    view.addSubview(refreshView)
    refreshView.center(inView: view)
    refreshView.isHidden = true
    
    }
    
    private func changeButtonBackground(){
        if isTimerRunning{
            button.setTitle("Stop", for: .normal)
        }
        else if seconds<=0{
            button.setTitle("Finish", for: .normal)
        }
    }
    
    private func makeCircle(redraw:Bool,stroke:CGFloat){
        // Use UIBezierPath as an easy way to create the CGPath for the layer.
         // The path should be the entire circle.
        if redraw{
            circleLayer.removeFromSuperlayer()
            underCircleLayer.removeFromSuperlayer()
        }
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: view.frame.size.width/2.0, y: view.frame.size.height / 2.0 - 50), radius: 150, startAngle: CGFloat(-Double.pi / 2), endAngle: CGFloat(3 * Double.pi / 2), clockwise: true)
         
         // Setup the CAShapeLayer with the path, colors, and line width
         circleLayer = CAShapeLayer()
         circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = Colors.endingGreen.cgColor
         circleLayer.lineWidth = 10.0;
        circleLayer.lineCap = .round
         // Don't draw the circle initially
         circleLayer.strokeEnd = stroke
        
        
        underCircleLayer.path = circlePath.cgPath
        underCircleLayer.fillColor = UIColor.clear.cgColor
        underCircleLayer.lineCap = .round
        underCircleLayer.lineWidth = 20.0
        underCircleLayer.strokeEnd = 1.0
        underCircleLayer.strokeColor = UIColor.black.cgColor
        // added circleLayer to layer
        view.layer.addSublayer(underCircleLayer)
         
         // Add the circleLayer to the view's layer's sublayers
        view.layer.addSublayer(circleLayer) //to add stuff on top of it
    }
    
    func animateCircle(duration: TimeInterval,from:Double) {
        print("Animation starting again")
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))

        // Set the animation duration appropriately
        animation.duration = duration

        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = from
        animation.toValue = 1

        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
        // right value when the animation ends.
        circleLayer.strokeEnd = 1.0

        // Do the actual animation
        circleLayer.add(animation, forKey: "animateCircle")
    }
    
    private func detectBackground(){
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
            //NotificationCenter.default.addObserver(self, selector: #selector(didComeBack), name: UIScene.willEnterForegroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(didComeBackFromSwiping), name: UIScene.didActivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }
    }
    
    private func startTimer(secondsLeft:TimeInterval,strokePoint:Double){
        isTimerRunning = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(upDateTime), userInfo: nil, repeats: true)
//        animateCircle(duration: Double(habit.time * 60) )
        animateCircle(duration: secondsLeft,from: strokePoint )
        if !notificationScheduled{
            let notification = Notification(id: "Remainder", title: "Time Up",body: "Time Up For \(habit.name)")
            LocalNotificationManager.shared.schedule(notification:notification,time: TimeInterval(seconds) )
            notificationScheduled = true
        }
       
        changeButtonBackground()

    }
    
    private func finishedTimer(){
        habit.nextDate = DateCalculator.getNextDate(freq: habit.frequency)
        //habit.nextDate = Date()
        habit.streak = habit.streak +  1
        
        DispatchQueue.main.async {
            self.refreshView.isHidden = false
            self.refreshIndicator.startAnimating()
        }
        
        DatabaseServices.shared.editHabit(habit: habit) {[weak self] (bool) in
            guard let self = self else {return}
            if bool{
                self.completion(self.habit)
                DispatchQueue.main.async {
                    self.refreshView.isHidden = true
                    self.refreshIndicator.stopAnimating()
                }
            }
            else{
                DispatchQueue.main.async {
                    self.completion(nil)
                    self.refreshView.isHidden = true
                    self.refreshIndicator.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
 
                }
            }
        }
    }
    
     @objc private func upDateTime(){
        if seconds > 0 {
            seconds -= 1
            let time = getTimeString(time: seconds)
            timerLabel.text = time
        }
        else{
            print("Invalidated")
            timer.invalidate()
            seconds = 0
            timerLabel.text = getTimeString(time: seconds)
            isTimerRunning = false
            changeButtonBackground()
            finishedTimer()
        }
    }
    
    private func getTimeString(time:Int) ->String {
        //print((Double(time)/60.0))
        //time is in INT So we wont get decimal numbers , so min will only be whole
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i",minutes, seconds)
    }
    
    private func getStrokePoint(secondsLeft:Int) ->Double {
        let totalSec = habit.time * 60
        let remaining = 1 - Double(secondsLeft)/Double(totalSec)
        return remaining
    }

}
