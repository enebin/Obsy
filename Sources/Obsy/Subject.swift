//
//  File.swift
//  
//
//  Created by Young Bin on 2023/02/25.
//
import Foundation
import Atomics

public class ObsySubject<Element>:
    ObserverType,
    ObservableType,
    UnsubscribeType,
    Cancelable
{
    private let sink = ObsySubjectSink<Element>()
    
    private let disposed = ManagedAtomic(false)
    public var isDisposed: Bool {
        disposed.load(ordering: .relaxed)
    }
    
    // MARK: - Publish
    public func on(_ event: Event<Element>) {
        if isDisposed { return }
        
        sink.on(event)
    }
    
    // MARK: - Subscribe
    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer: ObserverType<Element>
    {
        if isDisposed {
            sink.on(.error(ObsyError.disposed))
            return DisposableInstance.create()
        }
        
        let key = sink.insert(observer.asAnyObserver())
        return UnsubscribingDisposable(owner: self, observerKey: key)
    }
    
    // MARK: - Dispose
    public func dispose() {
        sink.removeAll()
        disposed.store(true, ordering: .relaxed)
    }
    
    func unsubscribe(key: ObserverKey) {
        sink.remove(key)
    }
}

struct UnsubscribingDisposable<T: UnsubscribeType>: Disposable {
    let owner: T
    let observerKey: T.KeyType
    
    func dispose() {
        owner.unsubscribe(key: observerKey)
    }
}

protocol UnsubscribeType {
    associatedtype KeyType
    func unsubscribe(key: KeyType)
}
