extension Effect {
    /// Task-local context for effect handler registration.
    ///
    /// `Effect.Context` provides scoped handler registration via Task-local storage.
    /// Use ``with(_:operation:)-5q3q7`` to register handlers for a scope:
    ///
    /// ```swift
    /// try await Effect.Context.with { handlers in
    ///     handlers[ConsoleHandler.self] = .live
    /// } operation: {
    ///     // ConsoleHandler.self resolves to .live here
    ///     Console.print("Hello")
    /// }
    /// ```
    ///
    /// ## Nested Scopes
    ///
    /// Handlers can be overridden in nested scopes:
    ///
    /// ```swift
    /// Effect.Context.with { handlers in
    ///     handlers[Logger.self] = .file
    /// } operation: {
    ///     // Logger is .file here
    ///     Effect.Context.with { handlers in
    ///         handlers[Logger.self] = .console
    ///     } operation: {
    ///         // Logger is .console here
    ///     }
    ///     // Logger is .file here again
    /// }
    /// ```
    ///
    /// ## Accessing Handlers
    ///
    /// Within a scope, access the current handlers:
    ///
    /// ```swift
    /// let console = Effect.Context.current[ConsoleHandler.self]
    /// ```
    public struct Context: Sendable {
        /// Task-local storage for the current context.
        @TaskLocal
        private static var _current: Context = Context(handlers: Handlers())

        /// The registered handlers in this context.
        public var handlers: Handlers

        internal init(handlers: Handlers) {
            self.handlers = handlers
        }
    }
}

// MARK: - Current Access

extension Effect.Context {
    /// The current handlers for this task.
    ///
    /// Returns the handlers from the innermost ``with(_:operation:)-5q3q7`` scope,
    /// or the default handlers if not in a scope.
    public static var current: Handlers {
        _current.handlers
    }
}

// MARK: - Scoped Registration (Synchronous)

extension Effect.Context {
    /// Executes a closure with modified handlers.
    ///
    /// This is the primary way to establish effect handling scope.
    /// Handlers registered here are visible to all code executed within
    /// the operation closure.
    ///
    /// - Parameters:
    ///   - modify: A closure that modifies the handlers for the scope.
    ///   - operation: The operation to execute with the modified handlers.
    /// - Returns: The result of the operation.
    /// - Throws: The typed error from the operation.
    public static func with<T, E: Error>(
        _ modify: (inout Handlers) -> Void,
        operation: () throws(E) -> T
    ) throws(E) -> T {
        var context = _current
        modify(&context.handlers)
        let result: Result<T, E> = $_current.withValue(context) {
            do throws(E) {
                return .success(try operation())
            } catch {
                return .failure(error)
            }
        }
        return try result.get()
    }

    /// Executes a closure with modified handlers (non-throwing).
    ///
    /// - Parameters:
    ///   - modify: A closure that modifies the handlers for the scope.
    ///   - operation: The operation to execute with the modified handlers.
    /// - Returns: The result of the operation.
    public static func with<T>(
        _ modify: (inout Handlers) -> Void,
        operation: () -> T
    ) -> T {
        var context = _current
        modify(&context.handlers)
        return $_current.withValue(context, operation: operation)
    }
}

// MARK: - Scoped Registration (Asynchronous)

extension Effect.Context {
    /// Executes an async closure with modified handlers.
    ///
    /// This is the primary way to establish async effect handling scope.
    /// Handlers registered here are visible to all code executed within
    /// the operation closure, including across await points.
    ///
    /// - Parameters:
    ///   - modify: A closure that modifies the handlers for the scope.
    ///   - operation: The async operation to execute with the modified handlers.
    /// - Returns: The result of the operation.
    /// - Throws: The typed error from the operation.
    public static func with<T, E: Error>(
        _ modify: (inout Handlers) -> Void,
        operation: () async throws(E) -> T
    ) async throws(E) -> T {
        var context = _current
        modify(&context.handlers)
        let result: Result<T, E> = await $_current.withValue(context) {
            do throws(E) {
                return .success(try await operation())
            } catch {
                return .failure(error)
            }
        }
        return try result.get()
    }

    /// Executes an async closure with modified handlers (non-throwing).
    ///
    /// - Parameters:
    ///   - modify: A closure that modifies the handlers for the scope.
    ///   - operation: The async operation to execute with the modified handlers.
    /// - Returns: The result of the operation.
    public static func with<T>(
        _ modify: (inout Handlers) -> Void,
        operation: () async -> T
    ) async -> T {
        var context = _current
        modify(&context.handlers)
        return await $_current.withValue(context, operation: operation)
    }
}
