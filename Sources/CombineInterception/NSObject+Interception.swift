#if canImport(Combine)
import Combine
import Foundation
@_spi(Internals) import Interception
import _InterceptionUtils

extension NSObject {
	/// Create a publisher which sends a `next` event at the end of every
	/// invocation of `selector` on the object.
	///
	/// It completes when the object deinitializes.
	///
	/// - warning: Observers to the resulting publisher should not call the method specified by the selector.
	///
	/// - parameters:
	///   - selector: The selector to observe.
	///
	/// - returns: A trigger publisher.
	public func publisher(for selector: Selector) -> some Publisher<Void, Never> {
		return intercept(selector).map { _ in }
	}


	public func intercept<Args, Output>(
		_ selector: _MethodSelector<Args, Output>
	) -> some Publisher<InterceptionResult<Args, Output>, Never> {
		intercept(selector.wrappedValue).map { result in
			result.unsafeCast(args: Args.self, output: Output.self)
		}
	}

	/// Create a publisher which sends a `next` event, containing an array of
	/// bridged arguments, at the end of every invocation of `selector` on the
	/// object.
	///
	/// It completes when the object deinitializes.
	///
	/// - warning: Observers to the resulting publisher should not call the method specified by the selector.
	///
	/// - parameters:
	///   - selector: The selector to observe.
	///
	/// - returns: A publisher that sends an array of bridged arguments.
	public func intercept(
		_ selector: Selector
	) -> some Publisher<InterceptionResult<Any, Any>, Never> {
		return _intercept(selector).publisher()
	}
}

extension InterceptionHandlers {
	func publisher() -> some Publisher<InterceptionResult<Any, Any>, Never> {
		(self[CombineInterceptionHandlerKey.shared] as? CombineInterceptionHandler).map(\.subject) ?? {
			let handler = CombineInterceptionHandler()
			self[CombineInterceptionHandlerKey.shared] = handler
			return handler.subject
		}()
	}
}

private struct CombineInterceptionHandler: InterceptionHandlerProtocol {
	let subject = PassthroughSubject<InterceptionResult<Any, Any>, Never>()

	func handle(_ result: InterceptionResult<Any, Any>) {
		subject.send(result)
	}
}

private struct CombineInterceptionHandlerKey: Hashable {
	static let shared: Self = .init()
	private init() {}
}
#endif
