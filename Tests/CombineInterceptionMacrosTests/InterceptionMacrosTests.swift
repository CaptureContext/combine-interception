import XCTest
@testable import CombineInterceptionMacros

final class InterceptionMacrosTests: XCTestCase {
	func testNoInputWithOutput() {
		let object = Object()
		var _args: [Void] = []
		var _outputs: [Int] = []
		var _expectedOutputs: [Int] = []
		var _count = 0

		let cancellable = object.intercept(#methodSelector(Object.zero)).sink { result in
			_args.append(result.args)
			_outputs.append(result.output)
			_count += 1
		}

		let runs = 3
		for _ in 0..<runs {
			_expectedOutputs.append(object.zero())
		}

		XCTAssertEqual(_count, runs)
		XCTAssertEqual(_args.count, runs)
		XCTAssertEqual(_outputs, _expectedOutputs)

		cancellable.cancel()
	}

	func testInputWithNoOutput() {
		let object = Object()
		var _args: [Int] = []
		var _outputs: [Void] = []
		var _count = 0

		let cancellable = object.intercept(#methodSelector(Object.discard)).sink { result in
			_args.append(result.args)
			_outputs.append(result.output)
			_count += 1
		}

		let runs = 3
		for i in 0..<runs { object.discard(i) }

		XCTAssertEqual(_count, runs)
		XCTAssertEqual(_args, .init(0..<runs))
		XCTAssertEqual(_outputs.count, runs)

		cancellable.cancel()
	}

	func testInputWithOutput() {
		let object = Object()
		var _args: [Int] = []
		var _outputs: [Bool] = []
		var _expectedOutputs: [Bool] = []
		var _count = 0

		let cancellable = object.intercept(#methodSelector(Object.booleanForInteger)).sink { result in
			_args.append(result.args)
			_outputs.append(result.output)
			_count += 1
		}

		let runs = 3
		for i in 0..<runs {
			_expectedOutputs.append(object.booleanForInteger(i))
		}

		XCTAssertEqual(_count, runs)
		XCTAssertEqual(_args, .init(0..<runs))
		XCTAssertEqual(_outputs, _expectedOutputs)

		cancellable.cancel()
	}

	func testSimpleMultipleInputsWithOutput() {
		let object = Object()
		var _args: [(Int, Int)] = []
		var _outputs: [Bool] = []
		var _expectedArgs: [(Int, Int)] = []
		var _expectedOutputs: [Bool] = []
		var _count = 0

		let cancellable = object.intercept(#methodSelector(Object.booleanAndForTwoIntegers)).sink { result in
			_args.append(result.args)
			_outputs.append(result.output)
			_count += 1
		}

		let outerRuns = 3
		let innerRuns = 3
		let runs = outerRuns * innerRuns
		for i in 0..<outerRuns {
			for j in 0..<innerRuns {
				_expectedArgs.append((i, j))
				_expectedOutputs.append(object.booleanAndForTwoIntegers(i, j))
			}
		}

		XCTAssertEqual(_count, runs)
		XCTAssertEqual(_args.map(Pair.init), _expectedArgs.map(Pair.init))
		XCTAssertEqual(_outputs, _expectedOutputs)

		cancellable.cancel()
	}

	func testMultipleInputsWithOutput() {
		let object = Object()
		var _args: [(Int, Bool)] = []
		var _outputs: [String] = []
		var _expectedArgs: [(Int, Bool)] = []
		var _expectedOutputs: [String] = []
		var _count = 0

		let cancellable = object.intercept(#methodSelector(Object.toString)).sink { result in
			_args.append(result.args)
			_outputs.append(result.output)
			_count += 1
		}

		let outerRuns = 3
		let innerRuns = 3
		let runs = outerRuns * innerRuns
		for i in 0..<outerRuns {
			for j in 0..<innerRuns {
				_expectedArgs.append((i, j.isMultiple(of: 2)))
				_expectedOutputs.append(object.toString(i, j.isMultiple(of: 2)))
			}
		}

		XCTAssertEqual(_count, runs)
		XCTAssertEqual(_args.map(Pair.init), _expectedArgs.map(Pair.init))
		XCTAssertEqual(_outputs, _expectedOutputs)

		cancellable.cancel()
	}
}

fileprivate class Object: NSObject {
	@discardableResult
	@objc dynamic
	func zero() -> Int { 0 }

	@objc dynamic
	func discard(_ value: Int) {}

	@discardableResult
	@objc dynamic
	func booleanForInteger(_ value: Int) -> Bool {
		value != 0
	}

	@objc dynamic
	func booleanAndForTwoIntegers(_ first: Int, _ second: Int) -> Bool {
		booleanForInteger(first) && booleanForInteger(second)
	}

	@objc dynamic
	func toString(_ first: Int, _ second: Bool) -> String {
		String(describing: (first, second))
	}
}

fileprivate struct Pair<Left: Equatable, Right: Equatable>: Equatable {
	var left: Left
	var right: Right

	init(_ pair: (Left, Right)) {
		self.left = pair.0
		self.right = pair.1
	}
}
