import XCTest
@testable import Obsy

fileprivate let nextValue = 3
fileprivate let errorValue = URLError(.badURL)
fileprivate let testQueue = DispatchQueue.global(qos: .userInitiated)

final class SubjectTests: XCTestCase {
    var obsySubject: ObsySubject<Int>!
    
    override func setUpWithError() throws {
        obsySubject = .init()
    }
    
    override func tearDownWithError() throws {
        obsySubject = nil
    }
    
    
    func testOnNextAndError() {
        let nextExpectation = XCTestExpectation()
        let errorExpectation = XCTestExpectation()
        
        _ = obsySubject.subscribe(
            onNext: { element in
                XCTAssertEqual(nextValue, element)
                nextExpectation.fulfill()
            },
            onError: { _ in
                errorExpectation.fulfill()
            })
        
        obsySubject.resolve(nextValue)
        obsySubject.reject(URLError(.badURL))
        
        wait(for: [nextExpectation, errorExpectation], timeout: 3)
    }
    
    func testOnNextReceiving() {
        let expectation = XCTestExpectation()
        
        _ = obsySubject.subscribe(
            onNext: { element in
                XCTAssertEqual(nextValue, element)
                expectation.fulfill()
            },
            onError: { _ in
                XCTFail()
            })
        
        obsySubject.resolve(nextValue)
        wait(for: [expectation], timeout: 3)
    }
    
    func testOnErrorReceiving() {
        let expectation = XCTestExpectation()

        _ = obsySubject.subscribe(
            onNext: { _ in
                XCTFail()
            },
            onError: { error in
                XCTAssertEqual(errorValue, error as! URLError)
                expectation.fulfill()
            })
        
        obsySubject.reject(errorValue)
        wait(for: [expectation], timeout: 3)
    }
    
    func testMutlipleSubscribe() throws {
        var expectations = [XCTestExpectation]()
        for _ in 0..<100 {
            let expectation = XCTestExpectation()
            _ = obsySubject.subscribe(
                onNext: { elem in
                    expectation.fulfill()
                },
                onError: { _ in
                    XCTFail()
                })
            
            expectations.append(expectation)
        }
        
        obsySubject.resolve(3)
        wait(for: expectations, timeout: 3)
    }
}
