//
//  File.swift
//  
//
//  Created by Young Bin on 2023/02/25.
//

import Foundation

final class ObsySubjectSink<Element> {
    private let lock = NSLock()
    private var observers: [AnyObserver<Element>] = []
    
    func insert(_ observer: AnyObserver<Element>) {
        lock.withLock {
            observers.append(observer)
        }
    }
    
    func on(_ event: Event<Element>) {
        observers.forEach { observer in
            observer.on(event)
        }
    }
}
