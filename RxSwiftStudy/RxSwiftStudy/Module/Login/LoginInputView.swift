//
//  LoginInputView.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/4.
//

import UIKit
import SnapKit
import RxSwift

fileprivate let margin = 20
fileprivate let inputViewHeight = 30
fileprivate let lengthLimit = 5

class LoginInputViewModel {
    // 输出
    let inputValid : Observable<Bool>
    
    init(input: Observable<String>) {
        inputValid = input.map { $0.count >= lengthLimit }.share(replay: 1)
    }
}

class LoginInputView : UIView, UITextFieldDelegate {
    private var nameLabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Oblique", size: 16)
        return label
    }()
    
    var input = {
        var field = UITextField()
        field.borderStyle = .roundedRect
        field.clearButtonMode = .always
        return field
    }()
    
    private var tips : String = ""
    private var tipsLabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont(name: "Avenir-Oblique", size: 14)
        return label
    }()
    
    private let disposeBag = DisposeBag()
    var viewModel : LoginInputViewModel!
    
    var inputText : String {
        input.text ?? "(null)"
    }
    
    init(name: String, isSecureTextEntry: Bool = false) {
        super.init(frame: .zero)
        
        nameLabel.text = name
        input.delegate = self
        input.isSecureTextEntry = isSecureTextEntry
        
        tips = "\(name) has to be at least \(lengthLimit) characters!"
        tipsLabel.text = tips
        
        layoutUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hiddenKeyboard() {
        if input.isEditing {
            input.resignFirstResponder()
        }
    }
}

extension LoginInputView {
    func layoutUI() {
        addSubview(nameLabel)
        addSubview(input)
        addSubview(tipsLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
        }
        
        input.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(inputViewHeight)
        }
        
        tipsLabel.snp.makeConstraints { make in
            make.top.equalTo(input.snp.bottom).offset(8)
            make.left.bottom.equalToSuperview()
        }
    }
    
    func bind() {
        viewModel = LoginInputViewModel(input: input.rx.text.orEmpty.asObservable())
        
        viewModel.inputValid.subscribe(onNext: {[weak self] hidden in
            self?.tipsLabel.text = hidden ?  "" : (self?.tips ?? "")
        }).disposed(by: disposeBag)
    }
}

extension LoginInputView {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
