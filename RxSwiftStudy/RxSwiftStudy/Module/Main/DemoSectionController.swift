//
//  DemoSectionController.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/28.
//

import IGListKit

final class DemoItem: NSObject {
    let name: String
    let controllerClass: UIViewController.Type

    init(name: String, controllerClass: UIViewController.Type) {
        self.name = name
        self.controllerClass = controllerClass
    }
}

extension DemoItem: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        name as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? DemoItem else { return false }
        return name == object.name && controllerClass == object.controllerClass
    }
}

final class DemoSectionController: ListSectionController {
    private var object: DemoItem?
    
    override func sizeForItem(at index: Int) -> CGSize {
        CGSize(width: collectionContext!.containerSize.width, height: 55)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionContext!.dequeueReusableCell(of: UICollectionViewCell.self, for: self, at: index)
        
        return cell
    }
}
