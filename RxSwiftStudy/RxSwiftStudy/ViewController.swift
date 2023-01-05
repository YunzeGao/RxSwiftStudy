//
//  ViewController.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/4.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    private lazy var loginButton : UIButton = {
        var btn = UIButton(type: .custom)
        btn.setTitle("Login", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor.red.cgColor
        return btn
    }()
    
    private lazy var GithubSignupButton : UIButton = {
        var btn = UIButton(type: .custom)
        btn.setTitle("Github Signup", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor.red.cgColor
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    func setupUI() {
        self.view.backgroundColor = UIColor.white
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.left.equalToSuperview().offset(44)
            make.right.equalToSuperview().offset(-44)
            make.height.equalTo(44)
        }
        
        view.addSubview(GithubSignupButton)
        GithubSignupButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(44)
            make.right.equalToSuperview().offset(-44)
            make.height.equalTo(44)
        }
    }
    
    func bind() {
        loginButton.rx.tap
            .subscribe(onNext: {[weak self] in self?.gotoLoginController()})
            .disposed(by: disposeBag)
        
        GithubSignupButton.rx.tap
            .subscribe(onNext: {[weak self] in self?.gotoGithubSignupController()})
            .disposed(by: disposeBag)
        
    }
}

extension ViewController {
    func gotoLoginController() {
        self.navigationController?.pushViewController(LoginController(), animated: true)
    }
    
    func gotoGithubSignupController() {
        self.navigationController?.pushViewController(SignupController(), animated: true)
    }
}

