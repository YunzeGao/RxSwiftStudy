//
//  LoginController.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/4.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

private let margin = 20
private let height = 20

class LoginController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    private var viewModel: LoginViewModel!
    
    private lazy var nameLabel : UILabel = {
        var label = UILabel()
        label.text = "UserName"
        label.font = UIFont(name: "Avenir-Oblique", size: 16)
        return label
    }()
    
    private lazy var nameInput : UITextField = {
        var field = UITextField()
        field.borderStyle = .roundedRect
        field.clearButtonMode = .always
        return field
    }()
    
    private lazy var nameValidTips : UILabel = {
        var label = UILabel()
        label.text = "Username has to be at least 5 characters!"
        label.textColor = UIColor.red
        label.font = UIFont(name: "Avenir-Oblique", size: 14)
        return label
    }()
    
    private lazy var passwordLabel : UILabel = {
        var label = UILabel()
        label.text = "Password"
        label.font = UIFont(name: "Avenir-Oblique", size: 16)
        return label
    }()
    
    private lazy var passwordInput : UITextField = {
        var field = UITextField()
        field.borderStyle = .roundedRect
        field.clearButtonMode = .always
        return field
    }()
    
    private lazy var passwordValidTips : UILabel = {
        var label = UILabel()
        label.text = "Password has to be at least 5 characters!"
        label.textColor = UIColor.red
        label.font = UIFont(name: "Avenir-Oblique", size: 14)
        return label
    }()
    
    private lazy var submitButton : UIButton = {
        var btn = UIButton(type: .custom)
        btn.setTitle("submit", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitleColor(.white, for: .disabled)
        btn.backgroundColor = .green
        btn.alpha = 0.6
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    func setupUI() {
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(nameLabel)
        self.view.addSubview(nameInput)
        self.view.addSubview(nameValidTips)
        self.view.addSubview(passwordLabel)
        self.view.addSubview(passwordInput)
        self.view.addSubview(passwordValidTips)
        self.view.addSubview(submitButton)
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(margin)
            make.left.equalToSuperview().offset(margin)
        }
        nameInput.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(margin)
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.height.equalTo(Double(height) * 1.5)
        }
        nameValidTips.snp.makeConstraints { make in
            make.top.equalTo(nameInput.snp.bottom).offset(margin)
            make.left.equalToSuperview().offset(margin)
        }
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(nameValidTips.snp.bottom).offset(margin)
            make.left.equalToSuperview().offset(margin)
        }
        passwordInput.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(margin)
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.height.equalTo(Double(height) * 1.5)
        }
        passwordValidTips.snp.makeConstraints { make in
            make.top.equalTo(passwordInput.snp.bottom).offset(margin)
            make.left.equalToSuperview().offset(margin)
        }
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(passwordValidTips.snp.bottom).offset(margin * 2)
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.height.equalTo(height * 2)
        }
    }
    
    func bind() {
        viewModel = LoginViewModel(username: nameInput.rx.text.orEmpty.asObservable(),
                                   password: passwordInput.rx.text.orEmpty.asObservable())
        
        
        viewModel.usernameValid
            .bind(to: nameValidTips.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.usernameValid
            .bind(to: passwordInput.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.passwordValid
            .bind(to: passwordValidTips.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.allValid.subscribe(onNext: { [weak self] enable in
            self?.submitButton.isEnabled = enable
            self?.submitButton.alpha = enable ? 1.0 : 0.6
        }).disposed(by: disposeBag)
        
        submitButton.rx.tap
            .subscribe(onNext: {[weak self] in self?.submit()})
            .disposed(by: disposeBag)
    }
}

extension LoginController {
    func submit() {
        print("username = \(nameInput.text!), password = \(passwordInput.text!)")
    }
}

