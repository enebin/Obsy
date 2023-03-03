//
//  File 2.swift
//  
//
//  Created by Young Bin on 2023/02/25.
//

import Foundation

/// 구독을 지원하는 객체가 따라야 하는 프로토콜
protocol ObservableType<Element> {
    associatedtype Element

    func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer: ObserverType<Element>
}

extension ObservableType {
    public func subscribe(
        onNext: @escaping (Element) -> Void,
        onError: @escaping (Error) -> Void,
        onDispose: (() -> Void)? = nil
    ) -> Disposable {
        let disposable: Disposable
        if let disposeAction = onDispose {
            disposable = DisposableInstance.create(with: disposeAction)
        } else {
            disposable = DisposableInstance.create()
        }
        
        let observer = AnyObserver<Element> { event in
            switch event {
            case .next(let value):
                onNext(value)
            case .error(let error):
                onError(error)
                disposable.dispose()
            }
        }
        
        return DisposableInstance.create(self.subscribe(observer), disposable)
    }
}
