//
//  LoginController.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/4.
//

import UIKit
import RxSwift
import RxGesture
import SnapKit

fileprivate let margin = 20
fileprivate let btnHeight = 40

class LoginViewModel {
    // 输出
    let allValid : Observable<Bool>
    
    // 输入
    init(usernameValid : Observable<Bool>, passwordValid : Observable<Bool>) {
        allValid = Observable
            .combineLatest(usernameValid, passwordValid) { $0 && $1 }
            .share(replay: 1)
    }
}

class LoginController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private var viewModel: LoginViewModel!
    
    private lazy var username = LoginInputView(name: "UserName")
    
    private lazy var password = LoginInputView(name: "Password", isSecureTextEntry: true)
    
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
        self.view.addSubview(username)
        self.view.addSubview(password)
        self.view.addSubview(submitButton)
        
        username.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(margin)
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
        }
        password.snp.makeConstraints { make in
            make.top.equalTo(username.snp.bottom).offset(margin)
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
        }
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(password.snp.bottom).offset(margin * 2)
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.height.equalTo(btnHeight)
        }
    }
    
    func bind() {
        viewModel = LoginViewModel(usernameValid: username.viewModel.inputValid,
                                   passwordValid: password.viewModel.inputValid)
        
        username.viewModel.inputValid
            .bind(to: password.input.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.allValid.subscribe(onNext: { [weak self] enable in
            self?.submitButton.isEnabled = enable
            self?.submitButton.alpha = enable ? 1.0 : 0.6
        }).disposed(by: disposeBag)
        
        submitButton.rx.tap
            .subscribe(onNext: {[weak self] in self?.submit()})
            .disposed(by: disposeBag)
        
        
        self.view.rx.tapGesture()
        .when(.recognized)
        .subscribe(onNext: { [weak self] _ in self?.hiddenKeyboard() })
        .disposed(by: disposeBag)
    }
}

extension LoginController {
    func submit() {
        print("username = \(username.inputText), password = \(password.inputText)")
    }
    
    func hiddenKeyboard() {
        username.hiddenKeyboard()
        password.hiddenKeyboard()
    }
}

