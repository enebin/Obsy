//
//  File 2.swift
//  
//
//  Created by Young Bin on 2023/02/25.
//

import Foundation

/// 구독을 지원하는 객체가 따라야 하는 프로토콜
public protocol ObservableType {
    associatedtype Element

    /// `Observer`를 받은 후 구독에 따른 이벤트 처리를 담당함
    func subscribe<Observer: ObserverType>(_ observer: Observer) where Observer.Element == Element
}
