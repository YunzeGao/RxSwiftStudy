//
//  SignupField.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/5.
//

import SnapKit
import RxSwift

class SignupField : UIView {
    enum FiledState : Int {
        case normal = 0
        case error
        case success
    }
    
    lazy var field = {
        var field = UITextField()
        field.borderStyle = .roundedRect
        field.clearButtonMode = .always
        field.autocorrectionType = .no;
        field.autocapitalizationType = .none
        return field
    }()
    
    lazy var tips = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont(name: "Avenir-Oblique", size: 14)
        return label
    }()
    
    init(_ placeholder : String, isSecureTextEntry: Bool = false) {
        super.init(frame: .zero)
        
        field.placeholder = placeholder
        field.isSecureTextEntry = isSecureTextEntry
        
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension SignupField {
    func layoutUI() {
        addSubview(field)
        addSubview(tips)
        
        field.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(30)
        }
        
        tips.snp.makeConstraints { make in
            make.top.equalTo(field.snp.bottom).offset(8)
            make.left.bottom.equalToSuperview()
        }
    }
}

extension SignupField {
    var text: String {
        field.text ?? "(null)"
    }
}

extension Reactive where Base : SignupField {
    var validationResult: Binder<SignupValidationResult> {
        return Binder(base) { field, result in
            field.tips.textColor = result.textColor
            field.tips.text = result.description
        }
    }
}
