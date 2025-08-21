import Foundation

@dynamicMemberLookup
public struct RBBJSONQuery<Base: Sequence<RBBJSON>>: CustomPlaygroundDisplayConvertible, CustomDebugStringConvertible {
    var base: Base

    init(_ base: Base) {
        self.base = base
    }

    /// Allows accessing the underlying sequence, e.g for mapping for the result
    /// of the query.
    public var ƒ: some Sequence<RBBJSON> {
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
    public subscript(index: Int) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(IndicesSequence(base: base, indices: [index]))
    }

    /// Matches multiple indices on a JSON array. Negative indices can be
    /// used to index from the end.
    public subscript(indices: Int...) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(IndicesSequence(base: base, indices: indices))
    }

    /// Matches a particular key on a JSON object.
    public subscript(key: String) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(KeySequence(key: key, base: base))
    }

    public subscript(keys: String...) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(KeysSequence(keys: keys, base: base))
    }

    /// Matches a particular key on a JSON object.
    public subscript(dynamicMember dynamicMember: String) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(KeySequence(key: dynamicMember, base: base))
    }

    /// Matches values on a JSON object or array that the given `keyPath`
    /// returns anything but `null` for, this includes values such as `0`,
    /// `false` or `""` that Javascript would consider falsy.
    public subscript(has keyPath: KeyPath<RBBJSON, RBBJSON>) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(PredicateSequence(predicate: { $0[keyPath: keyPath] != .null }, base: base))
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    public subscript(range: Range<Int>) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(RangeSequence(range: range, base: base))
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    public subscript(range: ClosedRange<Int>) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(RangeSequence(range: range.lowerBound ..< range.upperBound + 1, base: base))
    }

    public subscript(any axis: RBBJSON.Axis) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(AxisSequence(axis: axis, base: base))
    }

    /// Matches values on a JSON object or array that the given `predicate`
    /// returns `true` for.
    public subscript(matches predicate: @escaping (RBBJSON) -> Bool) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(PredicateSequence(predicate: predicate, base: base))
    }
}

public protocol RBBJSONQueryBacking: Sequence where Element == RBBJSON {

}

public extension RBBJSON {
    enum Axis {
        /// Matches any immediate child of a JSON object or array.
        case child

        /// Matches any immediate or transitive child of a JSON object or array as
        /// well as itself.
        case descendantOrSelf
    }

    /// Matches multiple indices on a JSON array. Negative indices can be
    /// used to index from the end.
    subscript(indices: Int...) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(IndicesSequence(base: CollectionOfOne(self), indices: indices))
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    subscript(range: Range<Int>) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(RangeSequence(range: range, base: CollectionOfOne(self)))
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    subscript(range: ClosedRange<Int>) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(RangeSequence(range: range.lowerBound ..< range.upperBound + 1, base: CollectionOfOne(self)))
    }

    /// Matches values on a JSON object or array that the given `predicate`
    /// returns `true` for.
    subscript(matches predicate: @escaping (RBBJSON) -> Bool) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(PredicateSequence(predicate: predicate, base: CollectionOfOne(self)))
    }

    /// Matches values on a JSON object or array that the given `keyPath`
    /// returns anything but `null` for, this includes values such as `0`,
    /// `false` or `""` that Javascript would consider falsy.
    subscript(has keyPath: KeyPath<RBBJSON, RBBJSON>) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        self[matches: { $0[keyPath: keyPath] != .null }]
    }

    subscript(any axis: Axis) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(AxisSequence(axis: axis, base: CollectionOfOne(self)))
    }

    subscript(keys: String...) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(KeysSequence(keys: keys, base: CollectionOfOne(self)))
    }
}

public extension Array where Element == RBBJSON {
    init(_ query: RBBJSONQuery<some Sequence<RBBJSON>>) {
        self.init(query.base)
    }
}

@dynamicMemberLookup
struct KeySequence<Base>: RBBJSONQueryBacking where Base: Sequence, Base.Element == RBBJSON {
    var key: String

    var base: Base

    public func makeIterator() -> AnyIterator<RBBJSON> {
        let underlying = base.lazy.map { $0[key] }
            .filter { $0 != .null }
        .makeIterator()

        return AnyIterator(underlying)
    }
}

@dynamicMemberLookup
struct KeysSequence<Base>: RBBJSONQueryBacking where Base: Sequence, Base.Element == RBBJSON {
    var keys: [String]

    var base: Base

    public func makeIterator() -> AnyIterator<RBBJSON> {
        let underlying = base
            .lazy
            .compactMap { object -> RBBJSON? in
                let keysAndValues: [(String, RBBJSON)] = keys.compactMap { key in
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
struct AnyChildSequence<Base>: RBBJSONQueryBacking where Base: Sequence, Base.Element == RBBJSON {
    var base: Base

    public func makeIterator() -> AnyIterator<RBBJSON> {
        let underlying = base.lazy.flatMap {
            RBBJSON.values($0)
        }
        .makeIterator()

        return AnyIterator(underlying)
    }
}

@dynamicMemberLookup
struct IndicesSequence<Base>: RBBJSONQueryBacking where Base: Sequence, Base.Element == RBBJSON {
    var base: Base

    var indices: [Int]

    public func makeIterator() -> AnyIterator<RBBJSON> {
        let underlying = base.lazy.flatMap { object -> [RBBJSON] in
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
struct RangeSequence<Base>: RBBJSONQueryBacking where Base: Sequence, Base.Element == RBBJSON {
    var range: Range<Int>

    var base: Base

    public func makeIterator() -> AnyIterator<RBBJSON> {
        let underlying = base.lazy.flatMap { object -> AnySequence<RBBJSON> in
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
struct PredicateSequence<Base>: RBBJSONQueryBacking where Base: Sequence, Base.Element == RBBJSON {
    var predicate: (RBBJSON) -> Bool

    var base: Base

    public func makeIterator() -> AnyIterator<RBBJSON> {
        let underlying = base.lazy.flatMap { object -> AnySequence<RBBJSON> in
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
struct AxisSequence<Base>: RBBJSONQueryBacking where Base: Sequence, Base.Element == RBBJSON {
    var axis: RBBJSON.Axis

    var base: Base

    public func makeIterator() -> AnyIterator<RBBJSON> {
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
    var json: RBBJSON

    struct Iterator: IteratorProtocol {
        typealias Element = RBBJSON

        var stack: [RBBJSON]

        mutating func next() -> RBBJSON? {
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


public extension RBBJSONQueryBacking {
    /// Matches a particular index on a JSON array. Negative indices can be
    /// used to index from the end.
    subscript(index: Int) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(IndicesSequence(base: self, indices: [index]))
    }

    /// Matches multiple indices on a JSON array. Negative indices can be
    /// used to index from the end.
    subscript(indices: Int...) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(IndicesSequence(base: self, indices: indices))
    }

    /// Matches a particular key on a JSON object.
    subscript(key: String) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(KeySequence(key: key, base: self))
    }

    subscript(keys: String...) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(KeysSequence(keys: keys, base: self))
    }

    /// Matches a particular key on a JSON object.
    subscript(dynamicMember dynamicMember: String) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(KeySequence(key: dynamicMember, base: self))
    }

    /// Matches values on a JSON object or array that the given `keyPath`
    /// returns anything but `null` for, this includes values such as `0`,
    /// `false` or `""` that Javascript would consider falsy.
    subscript(has keyPath: KeyPath<RBBJSON, RBBJSON>) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(PredicateSequence(predicate: { $0[keyPath: keyPath] != .null }, base: self))
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    subscript(range: Range<Int>) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(RangeSequence(range: range, base: self))
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    subscript(range: ClosedRange<Int>) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(RangeSequence(range: range.lowerBound ..< range.upperBound + 1, base: self))
    }

    subscript(any axis: RBBJSON.Axis) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(AxisSequence(axis: axis, base: self))
    }

    /// Matches values on a JSON object or array that the given `predicate`
    /// returns `true` for.
    subscript(matches predicate: @escaping (RBBJSON) -> Bool) -> RBBJSONQuery<some Sequence<RBBJSON>> {
        .init(PredicateSequence(predicate: predicate, base: self))
    }
}

internal extension Array where Element == RBBJSON {
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
