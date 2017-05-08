//
//  MockCreationModalityTests.swift
//  InstantMock
//
//  Created by Patrick on 08/05/2017.
//  Copyright © 2017 pirishd. All rights reserved.
//

import XCTest
@testable import InstantMock


protocol SomeProtocol {
    func someFunc(arg1: String, arg2: Int) -> String
}


class InheritanceMock: Mock, SomeProtocol {

    func someFunc(arg1: String, arg2: Int) -> String {
        return super.call(arg1, arg2)!
    }

    override init(withExpectationFactory factory: ExpectationFactory) {
        super.init(withExpectationFactory: factory)
    }

}


class DelegateItMock: Any, MockDelegate, SomeProtocol {

    private let expectationFactory: ExpectationFactory
    private let mock: Mock!

    init(withExpectationFactory factory: ExpectationFactory) {
        self.expectationFactory = factory
        self.mock = Mock(withExpectationFactory: expectationFactory)
    }

    var it: Mock {
        return self.mock
    }

    func someFunc(arg1: String, arg2: Int) -> String {
        return self.mock.call(arg1, arg2)!
    }

}


class DelegateFullMock: Any, MockDelegate, MockExpectation, MockStub, SomeProtocol {

    private let expectationFactory: ExpectationFactory
    private let mock: Mock!

    init(withExpectationFactory factory: ExpectationFactory) {
        self.expectationFactory = factory
        self.mock = Mock(withExpectationFactory: expectationFactory)
    }


    var it: Mock {
        return self.mock
    }

    func expect() -> Expectation {
        return self.mock.expect()
    }

    func verify() {
        self.mock.verify(file: #file, line: #line)
    }

    func stub() -> Stub {
        return self.mock.stub()
    }

    func someFunc(arg1: String, arg2: Int) -> String {
        return self.mock.call(arg1, arg2)!
    }

}


class MockCreationModalityTests: XCTestCase {

    private var assertionMock: AssertionMock!
    private var expectationFactory: ExpectationFactoryMock!


    override func setUp() {
        super.setUp()
        self.assertionMock = AssertionMock()
        self.expectationFactory = ExpectationFactoryMock(withAssertionMock: self.assertionMock)
    }


    func testExpect_inheritanceMock() {
        let mock = InheritanceMock(withExpectationFactory: self.expectationFactory)
        mock.expect().call(mock.someFunc(arg1: "Hello", arg2: Int.any))

        _ = mock.someFunc(arg1: "Hello", arg2: 2)

        mock.verify()
        XCTAssertTrue(self.assertionMock.succeeded)
    }


    func testExpect_delegateItMock() {
        let mock = DelegateItMock(withExpectationFactory: self.expectationFactory)
        mock.it.expect().call(mock.someFunc(arg1: "Hello", arg2: Int.any))

        _ = mock.someFunc(arg1: "Hello", arg2: 2)

        mock.it.verify()
        XCTAssertTrue(self.assertionMock.succeeded)
    }


    func testExpect_delegateFullMock() {
        let mock = DelegateFullMock(withExpectationFactory: self.expectationFactory)
        mock.expect().call(mock.someFunc(arg1: "Hello", arg2: Int.any))

        _ = mock.someFunc(arg1: "Hello", arg2: 2)

        mock.verify()
        XCTAssertTrue(self.assertionMock.succeeded)
    }

}