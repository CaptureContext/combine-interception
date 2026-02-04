import Testing
import Foundation
@testable import CombineInterception

@Suite("InterceptionTests")
struct InterceptionTests {
	@Suite("NoArgs")
	struct NoArgsTests {
		class Object: NSObject {
			@objc dynamic
			func void() { }

			@discardableResult
			@objc dynamic
			func zero() -> Int { 0 }
		}

		@Test
		func noOutput() async throws {
			let object = Object()

			var _interceptedArgs: [Void] = []
			var _interceptedOutputs: [Void] = []
			var _interceptionsCount = 0
			var _actualOutputs: [Void] = []

			let cancellable = object.intercept(_makeMethodSelector(
				selector: #selector(Object.void),
				signature: Object.void
			)).sink { result in
				_interceptionsCount += 1
				_interceptedArgs.append(result.args)
				_interceptedOutputs.append(result.output)
			}

			let runs = 3
			for _ in 0..<runs {
				_actualOutputs.append(object.void())
			}

			#expect(_interceptionsCount == runs)
			#expect(_interceptedArgs.count == runs)
			#expect(_interceptedOutputs.count == _actualOutputs.count)

			cancellable.cancel()
		}

		@Test
		func simpleOutput() async throws {
			let object = Object()

			var _interceptedArgs: [Void] = []
			var _interceptedOutputs: [Int] = []
			var _interceptionsCount = 0
			var _actualOutputs: [Int] = []

			let cancellable = object.intercept(_makeMethodSelector(
				selector: #selector(Object.zero),
				signature: Object.zero
			)).sink { result in
				_interceptionsCount += 1
				_interceptedArgs.append(result.args)
				_interceptedOutputs.append(result.output)
			}

			let runs = 3
			for _ in 0..<runs {
				_actualOutputs.append(object.zero())
			}

			#expect(_interceptionsCount == runs)
			#expect(_interceptedArgs.count == runs)
			#expect(_interceptedOutputs.count == _actualOutputs.count)

			cancellable.cancel()
		}
	}

	@Suite("WithArgs")
	struct WithArgsTests {
		class Object: NSObject {
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

		@Test
		func noOutput() async throws {
			let object = Object()

			var _interceptedArgs: [Int] = []
			var _interceptedOutputs: [Void] = []
			var _interceptionsCount = 0
			var _actualOutputs: [Void] = []

			let cancellable = object.intercept(_makeMethodSelector(
				selector: #selector(Object.discard),
				signature: Object.discard
			)).sink { result in
				_interceptionsCount += 1
				_interceptedArgs.append(result.args)
				_interceptedOutputs.append(result.output)
			}

			let runs = 3
			for i in 0..<runs {
				_actualOutputs.append(object.discard(i))
			}

			#expect(_interceptionsCount == runs)
			#expect(_interceptedArgs == .init(0..<runs))
			#expect(_actualOutputs.count == _interceptedOutputs.count)

			cancellable.cancel()
		}

		@Test
		func simpleOutput() async throws {
			let object = Object()

			var _interceptedArgs: [Int] = []
			var _interceptedOutputs: [Bool] = []
			var _interceptionsCount = 0
			var _actualOutputs: [Bool] = []

			let cancellable = object.intercept(_makeMethodSelector(
				selector: #selector(Object.booleanForInteger),
				signature: Object.booleanForInteger
			)).sink { result in
				_interceptionsCount += 1
				_interceptedArgs.append(result.args)
				_interceptedOutputs.append(result.output)
			}

			let runs = 3
			for i in 0..<runs {
				_actualOutputs.append(object.booleanForInteger(i))
			}

			#expect(_interceptionsCount == runs)
			#expect(_interceptedArgs == .init(0..<runs))
			#expect(_interceptedOutputs == _actualOutputs)

			cancellable.cancel()
		}

		func multipleOutputsSimpleOutput() async throws {
			do { // same type
				let object = Object()

				var _interceptedArgs: [(Int, Int)]  = []
				var _interceptedOutputs: [Bool] = []
				var _interceptionsCount = 0

				var _actualArgs: [(Int, Int)]  = []
				var _actualOutputs: [Bool] = []

				let cancellable = object.intercept(_makeMethodSelector(
					selector: #selector(Object.booleanAndForTwoIntegers),
					signature: Object.booleanAndForTwoIntegers
				)).sink { result in
					_interceptionsCount += 1
					_interceptedArgs.append(result.args)
					_interceptedOutputs.append(result.output)
				}

				let outerRuns = 3
				let innerRuns = 3
				let runs = outerRuns * innerRuns
				for i in 0..<outerRuns {
					for j in 0..<innerRuns {
						_actualArgs.append((i, j))
						_actualOutputs.append(object.booleanAndForTwoIntegers(i, j))
					}
				}

				#expect(_interceptionsCount == runs)
				#expect(_interceptedArgs.map(Pair.init) == _actualArgs.map(Pair.init))
				#expect(_interceptedOutputs == _actualOutputs)

				cancellable.cancel()
			}

			do { // different types
				let object = Object()

				var _interceptedArgs: [(Int, Bool)]  = []
				var _interceptedOutputs: [String] = []
				var _interceptionsCount = 0

				var _actualArgs: [(Int, Bool)]  = []
				var _actualOutputs: [String] = []

				let cancellable = object.intercept(_makeMethodSelector(
					selector: #selector(Object.toString),
					signature: Object.toString
				)).sink { result in
					_interceptionsCount += 1
					_interceptedArgs.append(result.args)
					_interceptedOutputs.append(result.output)
				}

				let outerRuns = 3
				let innerRuns = 3
				let runs = outerRuns * innerRuns
				for i in 0..<outerRuns {
					for j in 0..<innerRuns {
						_actualArgs.append((i, j.isMultiple(of: 2)))
						_actualOutputs.append(object.toString(i, j.isMultiple(of: 2)))
					}
				}

				#expect(_interceptionsCount == runs)
				#expect(_interceptedArgs.map(Pair.init) == _actualArgs.map(Pair.init))
				#expect(_interceptedOutputs == _actualOutputs)

				cancellable.cancel()
			}
		}
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
