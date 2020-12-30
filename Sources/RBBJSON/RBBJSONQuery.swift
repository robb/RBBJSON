import Foundation

@dynamicMemberLookup
public protocol RBBJSONQuery: Sequence, CustomPlaygroundDisplayConvertible where Element == RBBJSON {

}

extension RBBJSONQuery {
    var playgroundDescription: Any {
        map(\.playgroundDescription)
    }
}

public extension RBBJSON {
    enum Axis {
        /// Matches any immediate child of a JSON object or array.
        case child

        /// Matches any immediate and transitive child of a JSON object or array as
        /// well as itself.
        case descendantOrSelf
    }

    /// Matches multiple indices on a JSON array. Negative indices can be
    /// used to index from the end.
    subscript(indices: Int...) -> some RBBJSONQuery {
        IndicesSequence(base: CollectionOfOne(self), indices: indices)
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    subscript(range: Range<Int>) -> some RBBJSONQuery {
        RangeSequence(range: range, base: CollectionOfOne(self))
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    subscript(range: ClosedRange<Int>) -> some RBBJSONQuery {
        RangeSequence(range: range.lowerBound ..< range.upperBound + 1, base: CollectionOfOne(self))
    }

    /// Matches values on a JSON object or array that the given `predicate`
    /// returns `true` for.
    subscript(matches predicate: @escaping (RBBJSON) -> Bool) -> some RBBJSONQuery {
        PredicateSequence(predicate: predicate, base: CollectionOfOne(self))
    }

    /// Matches values on a JSON object or array that the given `keyPath`
    /// returns anything but `null` for, this includes values such as `0`,
    /// `false` or `""` that Javascript would consider falsy.
    subscript(has keyPath: KeyPath<RBBJSON, RBBJSON>) -> some RBBJSONQuery {
        self[matches: { $0[keyPath: keyPath] != .null }]
    }

    subscript(any axis: Axis) -> some RBBJSONQuery {
        AxisSequence(axis: axis, base: CollectionOfOne(self))
    }

    subscript(keys: String...) -> some RBBJSONQuery {
        KeysSequence(keys: keys, base: CollectionOfOne(self))
    }
}

extension RBBJSON {
    @dynamicMemberLookup
    struct KeySequence<Base>: RBBJSONQuery where Base: Sequence, Base.Element == RBBJSON {
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
    struct KeysSequence<Base>: RBBJSONQuery where Base: Sequence, Base.Element == RBBJSON {
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
    struct AnyChildSequence<Base>: RBBJSONQuery where Base: Sequence, Base.Element == RBBJSON {
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
    struct IndicesSequence<Base>: RBBJSONQuery where Base: Sequence, Base.Element == RBBJSON {
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
    struct RangeSequence<Base>: RBBJSONQuery where Base: Sequence, Base.Element == RBBJSON {
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
    struct PredicateSequence<Base>: RBBJSONQuery where Base: Sequence, Base.Element == RBBJSON {
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
    struct AxisSequence<Base>: RBBJSONQuery where Base: Sequence, Base.Element == RBBJSON {
        var axis: Axis

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

    struct RecursiveDescentSequence: RBBJSONQuery {
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
                        stack.append(contentsOf: Array(object.values).sortedIfDebug.reversedIfDebug)
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
}

public extension RBBJSONQuery {
    /// Matches a particular index on a JSON array. Negative indices can be
    /// used to index from the end.
    subscript(index: Int) -> some RBBJSONQuery {
        RBBJSON.IndicesSequence(base: self, indices: [index])
    }

    /// Matches multiple indices on a JSON array. Negative indices can be
    /// used to index from the end.
    subscript(indices: Int...) -> some RBBJSONQuery {
        RBBJSON.IndicesSequence(base: self, indices: indices)
    }

    /// Matches a particular key on a JSON object.
    subscript(key: String) -> some RBBJSONQuery {
        RBBJSON.KeySequence(key: key, base: self)
    }

    subscript(keys: String...) -> some RBBJSONQuery {
        RBBJSON.KeysSequence(keys: keys, base: self)
    }

    /// Matches a particular key on a JSON object.
    subscript(dynamicMember dynamicMember: String) -> some RBBJSONQuery {
        RBBJSON.KeySequence(key: dynamicMember, base: self)
    }

    /// Matches values on a JSON object or array that the given `keyPath`
    /// returns anything but `null` for, this includes values such as `0`,
    /// `false` or `""` that Javascript would consider falsy.
    subscript(has keyPath: KeyPath<RBBJSON, RBBJSON>) -> some RBBJSONQuery {
        RBBJSON.PredicateSequence(predicate: { $0[keyPath: keyPath] != .null }, base: self)
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    subscript(range: Range<Int>) -> some RBBJSONQuery {
        RBBJSON.RangeSequence(range: range, base: self)
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    subscript(range: ClosedRange<Int>) -> some RBBJSONQuery {
        RBBJSON.RangeSequence(range: range.lowerBound ..< range.upperBound + 1, base: self)
    }

    subscript(any axis: RBBJSON.Axis) -> some RBBJSONQuery {
        RBBJSON.AxisSequence(axis: axis, base: self)
    }

    /// Matches values on a JSON object or array that the given `predicate`
    /// returns `true` for.
    subscript(matches predicate: @escaping (RBBJSON) -> Bool) -> some RBBJSONQuery {
        RBBJSON.PredicateSequence(predicate: predicate, base: self)
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

internal extension Dictionary where Key: Comparable {
    #if DEBUG
    var sortedValuesIfDebug: [Value] {
        keys.sorted().compactMap { self[$0] }
    }
    #else
    var sortedValuesIfDebug: Dictionary<Key, Value>.Values {
        values
    }
    #endif
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

internal extension BidirectionalCollection {
    #if DEBUG
    var reversedIfDebug: ReversedCollection<Self> {
        reversed()
    }
    #else
    var reversedIfDebug: Self {
        self
    }
    #endif
}
