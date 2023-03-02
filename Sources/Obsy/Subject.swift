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
    func subscribe<Observer: ObserverType>(
        _ observer: Observer
    ) -> Disposable
    where
        Observer.Element == Element
    {
        if isDisposed {
            return DisposableInstance.create()
        }
        
        let key = sink.insert(observer.asAnyObserver())
        return UnsubscribingDisposable(owner: self, observerKey: key)
    }
    
    public func subscribe(
        onNext: @escaping (Element) -> Void,
        onError: @escaping (Error) -> Void,
        onDispose: (() -> Void)? = nil
    ) -> Disposable {
        if isDisposed {
            sink.on(.error(ObsyError.disposed))
            return DisposableInstance.create()
        }
        
            // Added
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
