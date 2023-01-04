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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    func setupUI() {
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.left.equalToSuperview().offset(44)
            make.right.equalToSuperview().offset(-44)
            make.height.equalTo(44)
        }
    }
    
    func bind() {
        loginButton.rx.tap
            .subscribe(onNext: {[weak self] in self?.loginBtnClicked()})
            .disposed(by: disposeBag)
    }
}

extension ViewController {
    func loginBtnClicked() {
        self.navigationController?.pushViewController(LoginController(), animated: true)
    }
}

