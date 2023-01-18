//
//  AlertService.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/20.
//

import UIKit
import RxSwift
import RxCocoa

protocol AlertActionType {
    var title: String? { get }
    var style: UIAlertAction.Style { get }
}

extension AlertActionType {
    var style: UIAlertAction.Style { .default }
}

protocol AlertServiceType {
    func show<Action: AlertActionType>(
        _ title: String?,
        _ message: String?,
        preferredStyle: UIAlertController.Style,
        actions: [Action]
    ) -> Observable<Action>
}

class AlertService : AlertServiceType {
    func show<Action>(_ title: String?, _ message: String?, preferredStyle: UIAlertController.Style, actions: [Action]) -> Observable<Action> where Action : AlertActionType {
        return Observable.create { observer in
            let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            for action in actions {
                let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
                    observer.onNext(action)
                    observer.onCompleted()
                }
                alert.addAction(alertAction)
            }
            let application = UIApplication.shared
            guard var rootVC : UIViewController = application.keyWindow?.rootViewController else {
                return Disposables.create {}
            }
            while let nextVC = rootVC.presentedViewController {
                rootVC = nextVC
            }
            rootVC.present(alert, animated: true)
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}
