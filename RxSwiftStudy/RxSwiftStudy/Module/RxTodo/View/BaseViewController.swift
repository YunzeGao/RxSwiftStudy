//
//  BaseViewController.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/20.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class BaseViewController: UIViewController {
    init() {
      super.init(nibName: nil, bundle: nil)
    }

    required convenience init?(coder aDecoder: NSCoder) {
      self.init()
    }
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        updateConfiguration()
        
        view.backgroundColor = .white
        makeUI()
        layoutUI()
    }
    
    func updateConfiguration() {
        
    }
    
    func makeUI() {
        
    }
    
    func layoutUI() {
        
    }
    
}
