//
//  ErrorViewController.swift
//  SimpleHabit
//
//  Created by Val V on 06/10/21.
//

import UIKit

class ErrorViewController: UIViewController {
    
    //MARK:Properties
    let titleString:String
    
    let message:String
    
    lazy var titleView : UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.font = UIFont.boldSystemFont(ofSize: 20)
        view.text = titleString
        return view
    }()
    
    lazy var messageView : UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.numberOfLines = 0
        view.font = UIFont.systemFont(ofSize: 18)
        view.text = message
        return view
    }()
    
    
    lazy var button:UIButton = {
        let button = UIButton()
        button.setTitle("OK", for: .normal)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    
    //MARK:LIFECYCLE
    init(title:String,message:String) {
        self.titleString = title
        self.message  = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        configureUI()
        super.viewDidLoad()

    }

    
    //MARK:Helpers
    func configureUI(){
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let stack = UIStackView(arrangedSubviews: [titleView,messageView,button])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.backgroundColor = .white
        stack.layer.borderWidth = 3
        stack.layer.borderColor = Colors.endingGreen.cgColor
        stack.layer.cornerRadius = 10
        
        
        
        view.addSubview(stack)
        stack.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.setDimensions(width: 280, height: 200)
        stack.center(inView: view)
        
    }
    
    
    //MARK:Selectors
    @objc func handleDismiss(){
        dismiss(animated: true, completion: nil)
    }
    
}
