//
//  File 2.swift
//  
//
//  Created by Young Bin on 2023/02/25.
//

/// `Observer`는 값을 방출할 수 있는 객체가 따르는 프로토콜
public protocol ObserverType {
    associatedtype Element
    
    /// Observer 객체에 값(`Event`)를 전달
    func on(_ event: Event<Element>)
}

internal extension ObserverType {
    func asAnyObserver() -> AnyObserver<Element> {
        AnyObserver(self)
    }
}

public extension ObserverType {
    /// onNext의 `typealias`
    func resolve(_ element: Element) {
        self.on(.next(element))
    }

    /// onError의 `typealias`
    func reject(_ error: Swift.Error) {
        self.on(.error(error))
    }
}

/// 프레임워크 내에서 사용할 수 있는 type free `Observer`.
///
/// `Observer`는 EventHandler의 typealias라고도 여길 수 있음
public struct AnyObserver<Element>: ObserverType {
    public typealias EventHandler = (Event<Element>) -> Void

    private let observer: EventHandler

    public init(eventHandler: @escaping EventHandler) {
        self.observer = eventHandler
    }
    
    public init<Observer: ObserverType>(_ observer: Observer) where Observer.Element == Element {
        self.observer = observer.on
    }
    
    public func on(_ event: Event<Element>) {
        self.observer(event)
    }
}
