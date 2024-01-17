import XCTest
@testable import CombineInterception

final class CombineInterceptionTests: XCTestCase {
	func testMain() {
		class Object: NSObject {
			@objc
			func booleanForInteger(_ value: NSNumber) -> Bool {
				value != 0
			}
		}

		let object = Object()
		var _args: [Int?] = []
		var _outputs: [Bool?] = []
		var _count = 0
		let cancellable = object.intercept(#selector(Object.booleanForInteger))
			.sink { selector in
				selector.args.first.flatMap { $0 as? Int }.map { _args.append($0) }
				selector.output.flatMap { $0 as? Bool }.map { _outputs.append($0) }
				_count += 1
			}

		object.performSelector(
			onMainThread: #selector(Object.booleanForInteger),
			with: 0,
			waitUntilDone: true
		)

		object.performSelector(
			onMainThread: #selector(Object.booleanForInteger),
			with: 1,
			waitUntilDone: true
		)

		XCTAssertEqual(_count, 2)
		XCTAssertEqual(_args, [0, 1])
		XCTAssertEqual(_outputs, [false, true])
		cancellable.cancel()
	}
}
