//
//  File.swift
//  
//
//  Created by Young Bin on 2023/02/25.
//

import Atomics
import Foundation

/// `Disposable`은 일회성 이벤트를 방출하는 객체에 대해 적용 가능합니다
public protocol Disposable {
    func dispose()
}

/// `Cancelable`은 여러번 이벤트를 방출하는 객체에 대해 적용 가능합니다.
public protocol Cancelable: Disposable {
    var isDisposed: Bool { get }
}

// MARK: Actual instance
public enum DisposableInstance {
    public static func create() -> Cancelable {
        DisposableSink(nil)
    }
    
    public static func create(with disposeAction: @escaping () -> Void) -> Cancelable {
        DisposableSink(disposeAction)
    }
    
    public static func create(_ disposable1: Disposable, _ disposable2: Disposable) -> Cancelable {
        BinaryDisposableSink(disposable1, disposable2)
    }
}

private final class DisposableSink: Cancelable {
    public typealias DisposeAction = () -> Void

    private var disposed = ManagedAtomic<Bool>(false)
    private var disposeAction: DisposeAction?

    public var isDisposed: Bool {
        disposed.load(ordering: .relaxed)
    }

    init(_ disposeAction: DisposeAction?) {
        self.disposeAction = disposeAction
    }

    func dispose() {
        if isDisposed == false {
            self.disposeAction?()
            self.disposed.store(true, ordering: .relaxed)
        }
    }
}

private final class BinaryDisposableSink: Cancelable {
    private let disposed = ManagedAtomic(false)

    private var disposable1: Disposable?
    private var disposable2: Disposable?

    /// - returns: Was resource disposed.
    var isDisposed: Bool {
        disposed.load(ordering: .relaxed)
    }
    
    init(_ disposable1: Disposable, _ disposable2: Disposable) {
        self.disposable1 = disposable1
        self.disposable2 = disposable2
    }

    func dispose() {
        if isDisposed == false {
            self.disposable1?.dispose()
            self.disposable2?.dispose()
            self.disposable1 = nil
            self.disposable2 = nil
            
            self.disposed.store(true, ordering: .relaxed)
        }
    }
}
