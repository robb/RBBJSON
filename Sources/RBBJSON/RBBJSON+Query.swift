import Foundation

public extension RBBJSON {
    /// Matches multiple indices on a JSON array. Negative indices can be
    /// used to index from the end.
    subscript(indices: Int...) -> Query {
        Query(json: self).appending(.indices(indices))
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    subscript(range: Range<Int>) -> Query {
        precondition(range.lowerBound >= 0, "Range must not have negative indices.")

        return Query(json: self)[range]
    }

    /// Matches a range of indices on a JSON array. Negative indices are not
    /// allowed.
    subscript(range: ClosedRange<Int>) -> Query {
        self[range.lowerBound ..< range.upperBound + 1]
    }

    /// Matches values on a JSON object or array that the given `predicate`
    /// returns `true` for.
    subscript(matches predicate: @escaping (RBBJSON) -> Bool) -> Query {
        Query(json: self)[matches: predicate]
    }

    /// Matches values on a JSON object or array that the given `keyPath`
    /// returns anything but `null` for, this includes values such as `0`,
    /// `false` or `""` that Javascript would consider falsy.
    subscript(has keyPath: KeyPath<RBBJSON, RBBJSON>) -> Query {
        Query(json: self)[has: keyPath]
    }

    subscript(any axis: Axis) -> Query {
        Query(json: self)[any: axis]
    }

    enum Axis {
        /// Matches any immediate child of a JSON object or array.
        case child

        /// Matches any immediate and transitive child of a JSON object or array as
        /// well as itself.
        case descendantOrSelf
    }


    /// A `Query` for accessing JSON data.
    ///
    /// Modeled after [JSONPath](https://goessner.net/articles/JsonPath/), use
    /// `Query` to selectively extract data from an `RBBJSON` value.
    ///
    /// A `Query` is always lazy, but does not implicitly confer laziness on
    /// algorithms applied to it.
    ///
    /// In other words, for an `RBBJSON` value `json`:
    ///
    /// * `json[any: .child]` does not create new storage but holds on to `j`.
    /// * `json[any: .child].map(f)` maps eagerly and returns a new array.
    /// * `json[any: .child].lazy.map(f)` maps lazily and returns a `LazyMapSequence`.
    @dynamicMemberLookup
    struct Query {
        enum Matcher {
            case root
            case descend
            case any
            case key(String)
            case indices([Int])
            case range(Range<Int>)
            case filterValues((RBBJSON) -> Bool)
        }

        var json: RBBJSON

        var matchers: [Matcher]

        internal init(json: RBBJSON, matchers: [Matcher] = [.root]) {
            self.json = json
            self.matchers = matchers
        }

        internal func appending(_ matcher: Matcher) -> Self {
            Query(json: json, matchers: self.matchers + [matcher])
        }

        /// Matches a particular key on a JSON object.
        public subscript(key: String) -> Self {
            appending(.key(key))
        }

        /// Matches a particular index on a JSON array. Negative indices can be
        /// used to index from the end.
        public subscript(index: Int) -> Self {
            appending(.indices([index]))
        }

        /// Matches multiple indices on a JSON array. Negative indices can be
        /// used to index from the end.
        public subscript(indices: Int...) -> Self {
            appending(.indices(indices))
        }

        /// Matches a range of indices on a JSON array. Negative indices are not
        /// allowed.
        public subscript(range: Range<Int>) -> Self {
            precondition(range.lowerBound >= 0, "Range must not have negative indices.")

            return appending(.range(range))
        }

        /// Matches a range of indices on a JSON array. Negative indices are not
        /// allowed.
        public subscript(range: ClosedRange<Int>) -> Self {
            self[range.lowerBound ..< range.upperBound + 1]
        }

        /// Matches a particular key on a JSON object.
        public subscript(dynamicMember dynamicMember: String) -> Self {
            appending(.key(dynamicMember))
        }

        /// Matches values on a JSON object or array that the given `predicate`
        /// returns `true` for.
        public subscript(matches predicate: @escaping (RBBJSON) -> Bool) -> Self {
            appending(.filterValues(predicate))
        }

        /// Matches values on a JSON object or array that the given `keyPath`
        /// returns anything but `null` for, this includes values such as `0`,
        /// `false` or `""` that Javascript would consider falsy.
        public subscript(has keyPath: KeyPath<RBBJSON, RBBJSON>) -> Self {
            appending(.filterValues { value in
                value[keyPath: keyPath] != .null
            })
        }

        public subscript(any axis: Axis) -> Self {
            switch axis {
            case .child:
                return appending(.any)
            case .descendantOrSelf:
                return appending(.descend)
            }
        }
    }
}

extension RBBJSON.Query: Sequence {
    /// A `Sequence` of `RBBJSON` values that matched a given `Query`.
    public struct Iterator: IteratorProtocol {
        public typealias Element = RBBJSON

        var searchIterator: SearchIterator

        lazy var resultIterator: AnyIterator<RBBJSON>? = {
            searchIterator.next()
        }()

        internal init(query: RBBJSON.Query) {
            searchIterator = SearchIterator(query: query)
        }

        public mutating func next() -> RBBJSON? {
            var result = resultIterator?.next()

            while result == nil, resultIterator != nil {
                result = resultIterator?.next()

                if result == nil {
                    resultIterator = searchIterator.next()
                }
            }

            return result
        }
    }

    public func makeIterator() -> Iterator {
        Iterator(query: self)
    }
}

internal struct SearchIterator: IteratorProtocol {
    public typealias Element = AnyIterator<RBBJSON>

    var stack: [(AnyIterator<RBBJSON>, ArraySlice<RBBJSON.Query.Matcher>)] = []

    init(query: RBBJSON.Query) {
        let matchers = query.matchers

        stack = [
            (
                AnyIterator(CollectionOfOne(query.json).makeIterator()),
                matchers[matchers.indices]
            )
        ]
    }

    public mutating func next() -> Element? {
        while !stack.isEmpty {
            let (iterator, allMatchers) = stack.last!

            guard let json = iterator.next() else {
                stack.removeLast()
                continue;
            }

            guard let currentMatcher = allMatchers.first else {
                fatalError("Exhausted matchers unexpectedly")
            }

            let nextMatchers = allMatchers.dropFirst()

            var nextResult: Element?

            switch (json, currentMatcher) {
            case (_, .root):
                nextResult = AnyIterator(CollectionOfOne(json).makeIterator())
            case (.null, _), (.bool, _), (.string, _), (.number, _):
                continue

            case (.object(let object), .descend):
                precondition(!nextMatchers.isEmpty)

                let values = object.sortedValuesIfDebug

                stack.append((AnyIterator(CollectionOfOne(json).makeIterator()), nextMatchers))
                stack.append((AnyIterator(values.makeIterator()), allMatchers))
            case (.object(let object), .any):
                guard !object.isEmpty else { continue }

                nextResult = AnyIterator(object.sortedValuesIfDebug.makeIterator())

            case (.object(let object), .key(let key)):
                guard let value = object[key] else { continue }

                nextResult = AnyIterator(CollectionOfOne(value).makeIterator())
            case (.object, .filterValues(let predicate)):
                if predicate(json) {
                    nextResult = AnyIterator(CollectionOfOne(json).makeIterator())
                }
            case (.object, .indices), (.object, .range):
                // Not supported
                continue

            case (.array(let array), .descend):
                precondition(!nextMatchers.isEmpty)

                stack.append((AnyIterator(CollectionOfOne(json).makeIterator()), nextMatchers))
                stack.append((AnyIterator(array.makeIterator()), allMatchers))
            case (.array(let array), .any):
                guard !array.isEmpty else { continue }

                nextResult = AnyIterator(array.makeIterator())
            case (.array(let array), .indices(let indices)):
                let values = indices.lazy.compactMap { array[wrapping: $0] }

                nextResult = AnyIterator(values.makeIterator())
            case (.array(let array), .range(let range)):
                precondition(range.lowerBound >= 0, "Ranges <0 are not supported.")

                let clampedRange = range.clamped(to: array.indices)

                let values = array[clampedRange]

                nextResult = AnyIterator(values.makeIterator())
            case (.array(let array), .filterValues(let predicate)):
                let values = array.lazy.filter(predicate)

                nextResult = AnyIterator(values.makeIterator())
            case (.array, .key):
                // Not supported
                continue
            }

            if let result = nextResult {
                if nextMatchers.isEmpty {
                    return nextResult
                } else {
                    stack.append((result, nextMatchers))
                }
            }
        }

        precondition(stack.isEmpty)

        return nil
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
