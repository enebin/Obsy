//
//  File.swift
//  
//
//  Created by Young Bin on 2023/02/25.
//

import Foundation
import Atomics

/// Sink는 해제 이벤트가 닿는 마지막 곳입니다.
/// Observer의 경우 Sink를 통해 해제 이벤트를 관리하기를 권합니다.
///

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
