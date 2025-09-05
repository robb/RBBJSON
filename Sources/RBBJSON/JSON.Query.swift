import Foundation

public extension JSON {
    @dynamicMemberLookup
    struct Query<Base: Sequence<JSON>>: CustomPlaygroundDisplayConvertible, CustomDebugStringConvertible {
        var base: Base

        init(_ base: Base) {
            self.base = base
        }

        /// Allows accessing the underlying sequence, e.g for mapping for the result
        /// of the query.
        public var ƒ: some Sequence<JSON> {
            base
        }

        public var debugDescription: String {
            base.map(\.debugDescription).joined(separator: ", ")
        }

        public var playgroundDescription: Any {
            base.map(\.playgroundDescription)
        }

        /// Matches a particular index on a JSON array. Negative indices can be
        /// used to index from the end.
        public subscript(index: Int) -> JSON.Query<some Sequence<JSON>> {
            .init(IndicesSequence(base: base, indices: [index]))
        }

        /// Matches multiple indices on a JSON array. Negative indices can be
        /// used to index from the end.
        public subscript(indices: Int...) -> JSON.Query<some Sequence<JSON>> {
            .init(IndicesSequence(base: base, indices: indices))
        }

        /// Matches a particular key on a JSON object.
        public subscript(key: String) -> JSON.Query<some Sequence<JSON>> {
            .init(KeySequence(key: key, base: base))
        }

        public subscript(keys: String...) -> JSON.Query<some Sequence<JSON>> {
            .init(KeysSequence(keys: keys, base: base))
        }

        public subscript(keyPaths: WritableKeyPath<JSON.Placeholder, JSON.Placeholder>...) -> JSON.Query<some Sequence<JSON>> {
            .init(KeyPathsSequence(keyPaths: keyPaths, base: base))
        }

        /// Matches a particular key on a JSON object.
        public subscript(dynamicMember dynamicMember: String) -> JSON.Query<some Sequence<JSON>> {
            .init(KeySequence(key: dynamicMember, base: base))
        }

        /// Matches values on a JSON object or array that the given `keyPath`
        /// returns anything but `null` for, this includes values such as `0`,
        /// `false` or `""` that Javascript would consider falsy.
        public subscript(has keyPath: KeyPath<JSON, JSON>) -> JSON.Query<some Sequence<JSON>> {
            .init(PredicateSequence(predicate: { $0[keyPath: keyPath] != .null }, base: base))
        }

        /// Matches a range of indices on a JSON array. Negative indices are not
        /// allowed.
        public subscript(range: Range<Int>) -> JSON.Query<some Sequence<JSON>> {
            .init(RangeSequence(range: range, base: base))
        }

        /// Matches a range of indices on a JSON array. Negative indices are not
        /// allowed.
        public subscript(range: ClosedRange<Int>) -> JSON.Query<some Sequence<JSON>> {
            .init(RangeSequence(range: range.lowerBound ..< range.upperBound + 1, base: base))
        }

        public subscript(any axis: JSON.Axis) -> JSON.Query<some Sequence<JSON>> {
            .init(AxisSequence(axis: axis, base: base))
        }

        /// Matches values on a JSON object or array that the given `predicate`
        /// returns `true` for.
        public subscript(matches predicate: @escaping (JSON) -> Bool) -> JSON.Query<some Sequence<JSON>> {
            .init(PredicateSequence(predicate: predicate, base: base))
        }
    }
}

public protocol _JSONQueryBacking: Sequence where Element == JSON {

}

public extension JSON {
    enum Axis {
        /// Matches any immediate child of a JSON object or array.
        case child

        /// Matches any immediate or transitive child of a JSON object or array as
        /// well as itself.
        case descendantOrSelf
    }

    /// Matches multiple indices on a JSON array. Negative indices can be
    /// used to index from the end.
    subscript(indices: Int...) -> JSON.Query<some Sequence<JSON>> {
        .init(IndicesSequence(base: CollectionOfOne(self), indices: indices))
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    subscript(range: Range<Int>) -> JSON.Query<some Sequence<JSON>> {
        .init(RangeSequence(range: range, base: CollectionOfOne(self)))
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    subscript(range: ClosedRange<Int>) -> JSON.Query<some Sequence<JSON>> {
        .init(RangeSequence(range: range.lowerBound ..< range.upperBound + 1, base: CollectionOfOne(self)))
    }

    /// Matches values on a JSON object or array that the given `predicate`
    /// returns `true` for.
    subscript(matches predicate: @escaping (JSON) -> Bool) -> JSON.Query<some Sequence<JSON>> {
        .init(PredicateSequence(predicate: predicate, base: CollectionOfOne(self)))
    }

    /// Matches values on a JSON object or array that the given `keyPath`
    /// returns anything but `null` for, this includes values such as `0`,
    /// `false` or `""` that Javascript would consider falsy.
    subscript(has keyPath: KeyPath<JSON, JSON>) -> JSON.Query<some Sequence<JSON>> {
        self[matches: { $0[keyPath: keyPath] != .null }]
    }

    subscript(any axis: Axis) -> JSON.Query<some Sequence<JSON>> {
        .init(AxisSequence(axis: axis, base: CollectionOfOne(self)))
    }

    subscript(keys: String...) -> JSON.Query<some Sequence<JSON>> {
        .init(KeysSequence(keys: keys, base: CollectionOfOne(self)))
    }

    subscript(keyPaths: WritableKeyPath<JSON.Placeholder, JSON.Placeholder>...) -> JSON.Query<some Sequence<JSON>> {
        .init(KeyPathsSequence(keyPaths: keyPaths, base: CollectionOfOne(self)))
    }
}

public extension Array where Element == JSON {
    init(_ query: JSON.Query<some Sequence<JSON>>) {
        self.init(query.base)
    }
}

@dynamicMemberLookup
struct KeySequence<Base>: _JSONQueryBacking where Base: Sequence, Base.Element == JSON {
    var key: String

    var base: Base

    public func makeIterator() -> AnyIterator<JSON> {
        let underlying = base.lazy.map { $0[key] }
            .filter { $0 != .null }
        .makeIterator()

        return AnyIterator(underlying)
    }
}

@dynamicMemberLookup
struct KeysSequence<Base>: _JSONQueryBacking where Base: Sequence, Base.Element == JSON {
    var keys: [String]

    var base: Base

    public func makeIterator() -> AnyIterator<JSON> {
        let underlying = base
            .lazy
            .compactMap { object -> JSON? in
                let keysAndValues: [(String, JSON)] = keys.compactMap { key in
                    let value = object[key]

                    guard value != .null else { return nil }

                    return (key, value)
                }

                if !keysAndValues.isEmpty {
                    return .object(Dictionary(keysAndValues) { a, _ in a })
                } else {
                    return nil
                }
            }
            .makeIterator()

        return AnyIterator(underlying)
    }
}

@dynamicMemberLookup
struct KeyPathsSequence<Base>: _JSONQueryBacking where Base: Sequence, Base.Element == JSON {
    var keyPaths: [WritableKeyPath<JSON.Placeholder, JSON.Placeholder>]

    var base: Base

    public func makeIterator() -> AnyIterator<JSON> {
        let underlying = base
            .lazy
            .compactMap { object -> JSON? in
                let keysAndValues: [(String, JSON)] = keyPaths.compactMap { key in
                    let value = object[placeholderKeyPath: key]

                    guard value != .null else { return nil }

                    return (key.lastComponentName!, value)
                }

                if !keysAndValues.isEmpty {
                    return .object(Dictionary(keysAndValues) { a, _ in a })
                } else {
                    return nil
                }
            }
            .makeIterator()

        return AnyIterator(underlying)
    }
}

@dynamicMemberLookup
struct AnyChildSequence<Base>: _JSONQueryBacking where Base: Sequence, Base.Element == JSON {
    var base: Base

    public func makeIterator() -> AnyIterator<JSON> {
        let underlying = base.lazy.flatMap {
            JSON.values($0)
        }
        .makeIterator()

        return AnyIterator(underlying)
    }
}

@dynamicMemberLookup
struct IndicesSequence<Base>: _JSONQueryBacking where Base: Sequence, Base.Element == JSON {
    var base: Base

    var indices: [Int]

    public func makeIterator() -> AnyIterator<JSON> {
        let underlying = base.lazy.flatMap { object -> [JSON] in
            let results = indices.map { object[$0] }.filter { $0 != .null }

            if results.isEmpty {
                return []
            } else {
                return results
            }
        }
        .makeIterator()

        return AnyIterator(underlying)
    }
}

@dynamicMemberLookup
struct RangeSequence<Base>: _JSONQueryBacking where Base: Sequence, Base.Element == JSON {
    var range: Range<Int>

    var base: Base

    public func makeIterator() -> AnyIterator<JSON> {
        let underlying = base.lazy.flatMap { object -> AnySequence<JSON> in
            switch object {
            case let .array(array):
                let clampedRange = range.clamped(to: array.indices)

                return AnySequence(array[clampedRange])
            default:
                return AnySequence(EmptyCollection())
            }
        }
        .makeIterator()

        return AnyIterator(underlying)
    }
}

@dynamicMemberLookup
struct PredicateSequence<Base>: _JSONQueryBacking where Base: Sequence, Base.Element == JSON {
    var predicate: (JSON) -> Bool

    var base: Base

    public func makeIterator() -> AnyIterator<JSON> {
        let underlying = base.lazy.flatMap { object -> AnySequence<JSON> in
            switch object {
            case let .array(array):
                return AnySequence(array.lazy.filter(predicate))
            case .object where predicate(object):
                return AnySequence(CollectionOfOne(object))
            default:
                return AnySequence(EmptyCollection())
            }
        }
        .makeIterator()

        return AnyIterator(underlying)
    }
}

@dynamicMemberLookup
struct AxisSequence<Base>: _JSONQueryBacking where Base: Sequence, Base.Element == JSON {
    var axis: JSON.Axis

    var base: Base

    public func makeIterator() -> AnyIterator<JSON> {
        switch axis {
        case .child:
            return AnyChildSequence(base: base).makeIterator()
        case .descendantOrSelf:
            let underlying = base.lazy.flatMap {
                RecursiveDescentSequence(json: $0)
            }
            .makeIterator()

            return AnyIterator(underlying)
        }
    }
}

struct RecursiveDescentSequence: Sequence {
    var json: JSON

    struct Iterator: IteratorProtocol {
        typealias Element = JSON

        var stack: [JSON]

        mutating func next() -> JSON? {
            while !stack.isEmpty {
                let json = stack.removeLast()

                switch json {
                case .null, .bool, .string, .number:
                    continue

                case .array(let array):
                    stack.append(contentsOf: array.reversed())
                    return json

                case .object(let object):
                    #if DEBUG
                    stack.append(contentsOf: Array(object.values).sortedIfDebug.reversed())
                    #else
                    stack.append(contentsOf: object.values)
                    #endif
                    return json
                }
            }

            return nil
        }
    }

    func makeIterator() -> Iterator {
        Iterator(stack: [json])
    }
}


public extension _JSONQueryBacking {
    /// Matches a particular index on a JSON array. Negative indices can be
    /// used to index from the end.
    subscript(index: Int) -> JSON.Query<some Sequence<JSON>> {
        .init(IndicesSequence(base: self, indices: [index]))
    }

    /// Matches multiple indices on a JSON array. Negative indices can be
    /// used to index from the end.
    subscript(indices: Int...) -> JSON.Query<some Sequence<JSON>> {
        .init(IndicesSequence(base: self, indices: indices))
    }

    /// Matches a particular key on a JSON object.
    subscript(key: String) -> JSON.Query<some Sequence<JSON>> {
        .init(KeySequence(key: key, base: self))
    }

    subscript(keys: String...) -> JSON.Query<some Sequence<JSON>> {
        .init(KeysSequence(keys: keys, base: self))
    }

    subscript(keyPaths: WritableKeyPath<JSON.Placeholder, JSON.Placeholder>...) -> JSON.Query<some Sequence<JSON>> {
        .init(KeyPathsSequence(keyPaths: keyPaths, base: self))
    }

    /// Matches a particular key on a JSON object.
    subscript(dynamicMember dynamicMember: String) -> JSON.Query<some Sequence<JSON>> {
        .init(KeySequence(key: dynamicMember, base: self))
    }

    /// Matches values on a JSON object or array that the given `keyPath`
    /// returns anything but `null` for, this includes values such as `0`,
    /// `false` or `""` that Javascript would consider falsy.
    subscript(has keyPath: KeyPath<JSON, JSON>) -> JSON.Query<some Sequence<JSON>> {
        .init(PredicateSequence(predicate: { $0[keyPath: keyPath] != .null }, base: self))
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    subscript(range: Range<Int>) -> JSON.Query<some Sequence<JSON>> {
        .init(RangeSequence(range: range, base: self))
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    subscript(range: ClosedRange<Int>) -> JSON.Query<some Sequence<JSON>> {
        .init(RangeSequence(range: range.lowerBound ..< range.upperBound + 1, base: self))
    }

    subscript(any axis: JSON.Axis) -> JSON.Query<some Sequence<JSON>> {
        .init(AxisSequence(axis: axis, base: self))
    }

    /// Matches values on a JSON object or array that the given `predicate`
    /// returns `true` for.
    subscript(matches predicate: @escaping (JSON) -> Bool) -> JSON.Query<some Sequence<JSON>> {
        .init(PredicateSequence(predicate: predicate, base: self))
    }
}

internal extension Array where Element == JSON {
    subscript(wrapping index: Int) -> Element? {
        if index < 0 {
            return self[safe: index + count]
        } else {
            return self[safe: index]
        }
    }

    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

internal extension Sequence where Element: Comparable {
#if DEBUG
    var sortedIfDebug: [Element] {
        sorted()
    }
#else
    var sortedIfDebug: Self {
        self
    }
#endif
}
