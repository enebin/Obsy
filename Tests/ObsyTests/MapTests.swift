//
//  MapTests.swift
//  
//
//  Created by 이영빈 on 2023/03/02.
//

import XCTest
@testable import Obsy

final class MapTests: XCTestCase {
    var obsySubject: ObsySubject<Int>!
    
    override func setUpWithError() throws {
        obsySubject = .init()
    }
    
    override func tearDownWithError() throws {
        obsySubject = nil
    }
    
    // Basic behavior
    func testMap() throws {
        let expectedValue = "5"
        let expectation = XCTestExpectation()
        
        _ = obsySubject
            .maps { val in
                return expectedValue
            }
            .subscribe(
                onNext: { value in
                    XCTAssertEqual(value, expectedValue)
                    expectation.fulfill()
                },
                onError: { _ in }
            )
        
        obsySubject.resolve(4)
        wait(for: [expectation], timeout: 3)
    }
    
    func testThrowInsideMap() throws {
        let errorExp = XCTestExpectation()
        let disposeExp = XCTestExpectation()
        
        _ = obsySubject
            .maps { val in
                throw URLError(.badURL)
            }
            .subscribe(
                onNext: { _ in
                    XCTFail("Shouldn't be called after error")
                },
                onError: { _ in
                    errorExp.fulfill()
                },
                onDispose: {
                    disposeExp.fulfill()
                }
            )
        
        obsySubject.resolve(3)
        
        wait(for: [errorExp, disposeExp], timeout: 3)
    }
    
    func testDisposeMap() throws {
        let expectation = XCTestExpectation()
        expectation.isInverted = true
        
        let disposeExp = XCTestExpectation()
        
        let observer = obsySubject
            .maps { val in
                return "test"
            }
            .subscribe(
                onNext: { _ in
                    expectation.fulfill()
                },
                onError: { _ in
                    expectation.fulfill()
                },
                onDispose: {
                    disposeExp.fulfill()
                }
            )
        
        observer.dispose()
        obsySubject.resolve(4)
        wait(for: [expectation, disposeExp], timeout: 3)
    }
    
    func testDisposeMapAfterError() throws {
        let errorExp = XCTestExpectation()
        let disposeExp = XCTestExpectation()
        
        _ = obsySubject
            .maps { val in
                return "test"
            }
            .maps { val in
                return 3
            }
            .subscribe(
                onNext: { _ in
                    XCTFail("Shouldn't be called after error")
                },
                onError: { _ in
                    errorExp.fulfill()
                },
                onDispose: {
                    disposeExp.fulfill()
                }
            )
        
        obsySubject.reject(URLError(.badURL))
        obsySubject.resolve(3)
        
        wait(for: [errorExp, disposeExp], timeout: 3)
    }
}
