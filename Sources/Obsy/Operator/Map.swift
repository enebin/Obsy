//
//  File.swift
//
//
//  Created by 이영빈 on 2023/03/02.
//

import Foundation
import Atomics

extension ObservableType {
    public func maps<Result>(_ transform: @escaping (Element) throws -> Result) -> some ObservableType<Result> {
        Map(source: self, transform: transform)
    }
}

private struct Map<SourceType, ResultType, Source: ObservableType<SourceType>>: ObservableType {
    typealias Element = ResultType
    typealias Transform = (SourceType) throws -> ResultType
    
    private let source: Source
    private let transform: Transform

    init(source: Source, transform: @escaping Transform) {
        self.source = source
        self.transform = transform
    }
    
    func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer: ObserverType<ResultType> {
        let mapped = MapSink(transform: transform, observer: observer)
        let subscription = self.source.subscribe(mapped)
        
        return subscription
    }
}

private struct MapSink<SourceType, Observer: ObserverType>: ObserverType, Cancelable {
    typealias Transform = (SourceType) throws -> ResultType
    typealias ResultType = Observer.Element
    
    typealias Element = SourceType

    private let transform: Transform
    private let source: Observer

    init(transform: @escaping Transform, observer: Observer) {
        self.transform = transform
        self.source = observer
    }
    
    func on(_ event: Event<SourceType>) {
        switch event {
        case .next(let element):
            do {
                if isDisposed {
                    throw ObsyError.disposed
                }
                
                let mappedElement = try transform(element)
                source.resolve(mappedElement)
            }
            catch let error {
                source.reject(error)
                dispose()
            }
        case .error(let error):
            source.reject(error)
            dispose()
        }
    }
    
    // MARK: - Disposing
    private var disposed = ManagedAtomic<Bool>(false)
    var isDisposed: Bool {
        disposed.load(ordering: .relaxed)
    }
    
    func dispose() {
        disposed.store(true, ordering: .relaxed)
    }
}
