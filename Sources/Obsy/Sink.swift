//
//  File.swift
//  
//
//  Created by Young Bin on 2023/02/25.
//

import Foundation

final class ObsySubjectSink<Element> {
    private let lock = NSLock()
    private var observers: [ObserverKey: AnyObserver<Element>] = [:]
    
    func insert(_ observer: AnyObserver<Element>) -> ObserverKey {
        lock.withLock {
            let key = ObserverKey()
            observers[key] = observer
            
            return key
        }
    }
    
    func remove(_ key: ObserverKey) {
        lock.withLock {
            _ = observers.removeValue(forKey: key)
        }
    }
    
    func removeAll() {
        lock.withLock {
            observers.removeAll()
        }
    }
    
    func on(_ event: Event<Element>) {
        observers.values.forEach { observer in
            observer.on(event)
        }
    }
}

struct ObserverKey: Hashable {
    let value: UUID = UUID()
}
