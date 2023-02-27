//
//  File.swift
//  
//
//  Created by Young Bin on 2023/02/25.
//
import Foundation

public class ObsySubject<Element>:
    ObserverType,
    ObservableType
{
    let sink = ObsySubjectSink<Element>()
    
    public func on(_ event: Event<Element>) {
        sink.on(event)
    }
    
    public func subscribe<Observer: ObserverType>(_ observer: Observer) where Observer.Element == Element {
        sink.insert(observer.asAnyObserver())
    }
    
    public func subscribe(
        onNext: @escaping (Element) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        let observer = AnyObserver<Element> { event in
            switch event {
            case .next(let value):
                onNext(value)
            case .error(let error):
                onError(error)
            }
        }
        
        self.subscribe(observer)
    }
}
