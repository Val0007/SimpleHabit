//
//  ViewController.swift
//  SimpleHabit
//
//  Created by Val V on 07/08/21.
//

import UIKit

class BaseViewController: UIViewController {

    //MARK:PROPERTIES
    var selectedRow = -1
    var isSelected  = false
    
    var habits:[Habit] = []{
        didSet{
            DispatchQueue.main.async {
                print("RELOADING")
                self.tableView.reloadData()
            }
        }
    }
    
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
    
    let tableView:UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.backgroundColor = Colors.baseColor
        tv.isUserInteractionEnabled = true
        return tv
    }()
    
    let titleText:UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = Fonts().titleFont
        label.text = "Timely Habits"
        return label
    }()
    
    let titleContainer:UIView = {
        let view  = UIView()
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    let addButton:UIButton  = {
        let button = UIButton()
        button.backgroundColor = Colors.buttonGreen
        let config = UIImage.SymbolConfiguration(
            pointSize: 20, weight: .bold, scale: .medium)
        let image = UIImage(systemName: "plus", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        return button
    }()
    
    
    
    //MARK:LIFECYCLE
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.baseColor
        makeUI()
        refreshView.isHidden = false
        refreshIndicator.startAnimating()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HabitCell.self, forCellReuseIdentifier: "cell")
        DatabaseServices.shared.fetchHabits {[weak self] (habits) in
            guard let habits  = habits else {
                DispatchQueue.main.async {
                    self?.showAlert(title: "ERROR", msg: "No Network Connection,Try Again")
                }
                return
            }
            self?.habits = habits
            DispatchQueue.main.async {
                self?.refreshIndicator.stopAnimating()
                self?.refreshView.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if selectedRow > -1{
            print("SELECTED ROW IS \(selectedRow)")
            let indexPath = IndexPath(row: selectedRow, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! HabitCell
            DispatchQueue.main.async {
                cell.isExpanded = true
            }
        }

    }

    //MARK:SELECTORS
    func presentInputView(isEdit:Bool,habit:Habit?,editCompletion:((Habit)->())?){
        print("YES")
        if isEdit{
            guard let habit = habit else {return}
            let vc = InputView()
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.isEdit = true
            vc.habit = habit
            vc.editCompletion = { habit in
                guard let habit = habit else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Could not Update", msg: "Network Error!,Try again")
                    }
                    return}
                if let completion = editCompletion{
                    completion(habit)
                }
            }
            present(vc, animated: true, completion: nil)
            
        }
        else{
            let vc = InputView()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.completion = { [weak self]habit in
                guard let self  = self else {return}
                guard let habit = habit else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Could not Update", msg: "Network Error!,Try again")
                    }
                    return}
                self.selectedRow = -1
                self.isSelected = false
                self.habits.append(habit)
                
            }
            present(vc, animated: true, completion: nil)
        }

    }
    
    @objc func handleAdd(){
        presentInputView(isEdit: false, habit: nil,editCompletion: nil)
    }
    
    
    
    //MARK:HELPERS
    func makeUI(){
        view.addSubview(titleContainer)
        titleContainer.anchor(top:view.safeAreaLayoutGuide.topAnchor,left: view.safeAreaLayoutGuide.leftAnchor,right: view.safeAreaLayoutGuide.rightAnchor,paddingTop: 10)
        titleContainer.addSubview(titleText)
        titleText.centerY(inView: titleContainer)
        titleText.anchor(left:titleContainer.leftAnchor,paddingLeft:10)
        titleContainer.addSubview(addButton)
        addButton.centerY(inView: titleContainer)
        addButton.anchor(right:titleContainer.rightAnchor,paddingRight: 10)
        
        view.addSubview(tableView)
        tableView.anchor(top: titleContainer.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 30, paddingLeft: 10,paddingRight: 10)
        
        view.addSubview(refreshView)
        refreshView.center(inView: view)
    }

}


extension BaseViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HabitCell
        cell.habit = habits[indexPath.row]
        cell.selectionStyle = .none
        cell.delegate = self
        cell.isExpanded = false
        cell.afterEditHabit = { habit in
            self.selectedRow = -1
            self.isSelected = false
            self.habits[indexPath.row] = habit
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {


        let habit = habits[indexPath.row]
        
        DispatchQueue.main.async {
            self.refreshView.isHidden = false
            self.refreshIndicator.startAnimating()
        }
        
        
        DatabaseServices.shared.deleteHabit(habit: habit) {[weak self] bool in
            guard let self  = self else {return}
            if bool{
                if indexPath.row == self.selectedRow {
                    self.selectedRow = -1
                    self.isSelected = false
                }
                print("Deleted")
                self.habits.remove(at: indexPath.row)
                
                DispatchQueue.main.async {
                    self.refreshView.isHidden = true
                    self.refreshIndicator.stopAnimating()
                }

            }
            else{
                DispatchQueue.main.async {
                    self.refreshView.isHidden = true
                    self.refreshIndicator.stopAnimating()
                    self.showAlert(title: "Could not Update", msg: "Network Error!,Try again")
                }

            }
        }
        
      }
    }
    
    
}

extension BaseViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedRow != indexPath.row && !isSelected{
            selectedRow = indexPath.row
            isSelected.toggle()

            //SELECTED ROW WILL BE THIS INDEXPATH AND HENCE MORE HEIGHT WILL BE GIVEN WHEN RELOADING
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            //AFTER MORE HEIGHT IS ALLOTTED WE MAKE CHANGES TO THE UI
            let cell = tableView.cellForRow(at: indexPath) as! HabitCell
            cell.isExpanded = isSelected

        }
        else if isSelected && selectedRow != indexPath.row{
            let indexPathForPreviousCell = IndexPath(row: selectedRow, section: indexPath.section)
            selectedRow = indexPath.row
            
            //make it small and make the currently selected one bigger
            tableView.reloadRows(at: [indexPathForPreviousCell,indexPath], with: .automatic)
            
            let cell = tableView.cellForRow(at: indexPath) as! HabitCell
            cell.isExpanded = isSelected
            
        }
        else{
            selectedRow = -1
            isSelected.toggle()
            print("IT IS SELECTED")
            //DESELECTED ROW WILL BE THIS INDEXPATH AND HENCE Less HEIGHT WILL BE GIVEN WHEN RELOADING
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            
        }

        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == selectedRow {
            return 240
        }
        return 100
    }
}

extension BaseViewController:HabitCellDelegate{
    func startTimer(habit: Habit,cell:HabitCell) {
        let vc  = TimerVC(habit: habit) {[weak self] habit in
     
            guard let habit  = habit else {
                self?.showAlert(title: "Could Not Update", msg: "Network Error!")
                return}
            DispatchQueue.main.async {
                cell.habit = habit
                cell.upDateValue()
                guard let self = self else {return}
                guard let indexPath = self.tableView.indexPath(for: cell) else {return}
                self.habits[indexPath.row] = habit
            }


        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    func editHabit(habit: Habit,cell:HabitCell) {
        presentInputView(isEdit: true, habit: habit) { [weak self](habit) in
            
            cell.habit = habit
            cell.upDateValue()
            guard let self = self else {return}
            guard let indexPath = self.tableView.indexPath(for: cell) else {return}
            self.selectedRow = -1
            self.isSelected = false
            self.habits[indexPath.row] = habit

        }
    }
    
    func expandCell(){
        if selectedRow > -1 && isSelected{
            let indexPath  = IndexPath(row: selectedRow, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as! HabitCell
            cell.isExpanded = true
        }

    }
    
    
}

extension UIViewController{
    func showAlert(title:String,msg:String){
        
        DispatchQueue.main.async {
            let alertView = ErrorViewController(title:title, message: msg)
            alertView.modalPresentationStyle = .overFullScreen
            alertView.modalTransitionStyle = .crossDissolve
            self.present(alertView, animated: true, completion: nil)

        }
}
    
}
