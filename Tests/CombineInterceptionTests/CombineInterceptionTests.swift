import XCTest
@testable import CombineInterception

// Tested extensively here
// https://github.com/maximkrouk/ReactiveCocoa/blob/interception-improvements/ReactiveCocoaTests/InterceptingSpec.swift
final class CombineInterceptionTests: XCTestCase {
	func testMain() {
		class Object: NSObject {
			@objc dynamic
			func booleanForInteger(_ value: Int) -> Bool {
				value != 0
			}
		}

		let object = Object()
		var _args: [Int?] = []
		var _outputs: [Bool?] = []
		var _count = 0
		let cancellable = object.intercept(#selector(Object.booleanForInteger))
			.sink { selector in
				selector.args.first.flatMap { $0 as? NSNumber }.map(\.intValue).map { _args.append($0) }
				selector.output.flatMap { $0 as? Bool }.map { _outputs.append($0) }
				_count += 1
			}

		XCTAssertFalse(object.booleanForInteger(0))
		XCTAssertTrue(object.booleanForInteger(1))

		XCTAssertEqual(_count, 2)
		XCTAssertEqual(_args, [0, 1])
		XCTAssertEqual(_outputs, [false, true])

		cancellable.cancel()
	}
}
