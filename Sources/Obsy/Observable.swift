//
//  File 2.swift
//  
//
//  Created by Young Bin on 2023/02/25.
//

import Foundation

/// 구독을 지원하는 객체가 따라야 하는 프로토콜
protocol ObservableType {
    associatedtype Element

    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element
}
