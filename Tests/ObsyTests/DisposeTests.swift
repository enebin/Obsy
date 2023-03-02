//
//  DisposeTests.swift
//  
//
//  Created by 이영빈 on 2023/02/27.
//

import XCTest
@testable import Obsy

fileprivate let nextValue = 3
fileprivate let errorValue = URLError(.badURL)
fileprivate let testQueue = DispatchQueue.global(qos: .userInitiated)

final class DisposeTests: XCTestCase {
    var obsySubject: ObsySubject<Int>!
    
    override func setUpWithError() throws {
        obsySubject = .init()
    }
    
    override func tearDownWithError() throws {
        obsySubject = nil
    }

    // MARK: Dispose test
    func testOnDispose() throws {
        let expectation = XCTestExpectation()
        
        let observer = obsySubject.subscribe(
            onNext: { element in
                XCTFail()
            },
            onError: { _ in
                XCTFail()
            },
            onDispose: {
                expectation.fulfill()
            })
        
        observer.dispose()
        wait(for: [expectation], timeout: 3)
    }
    
    func testActionAfterDispose() throws {
        let expectation = XCTestExpectation()
        expectation.isInverted = true
        
        let observer = obsySubject.subscribe(
            onNext: { element in
                expectation.fulfill()
            },
            onError: { _ in
                expectation.fulfill()
            })
        
        observer.dispose()
        obsySubject.resolve(nextValue)
        obsySubject.reject(URLError(.badURL))
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testActionAfterError() throws {
        let onNextExpectation = XCTestExpectation()
        let onErrorExpectation = XCTestExpectation()
        let onDisposeExpectation = XCTestExpectation()
        
        _ = obsySubject.subscribe(
            onNext: { element in
                onNextExpectation.fulfill()
            },
            onError: { _ in
                onErrorExpectation.fulfill()
            },
            onDispose: {
                onDisposeExpectation.fulfill()
            }
        )
        
        obsySubject.resolve(nextValue)
        obsySubject.reject(URLError(.badURL))
        
        wait(for: [onNextExpectation, onErrorExpectation, onDisposeExpectation], timeout: 3)
    }
    
    func testSubjectDisposeAndEmit() throws {
        let expectation = XCTestExpectation()
        expectation.isInverted = true
        
        obsySubject.dispose()
        
        _ = obsySubject.subscribe(
            onNext: { element in
                expectation.fulfill()
            },
            onError: { _ in
                expectation.fulfill()
            })
        
        obsySubject.resolve(nextValue)
        obsySubject.reject(URLError(.badURL))
        
        wait(for: [expectation], timeout: 1)
    }
}
