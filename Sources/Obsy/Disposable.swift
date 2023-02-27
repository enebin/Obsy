//
//  File.swift
//  
//
//  Created by Young Bin on 2023/02/25.
//

import Foundation

// MARK: - Disposable
public protocol Disposable {
    func dispose()
}

//extension ObservableType {
//    public func asObservable() -> Observable<Element> {
//        Observable.create { o in self.subscribe(o) }
//    }
//}
