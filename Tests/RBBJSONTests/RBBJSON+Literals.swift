import RBBJSON

extension RBBJSON: @retroactive ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

extension RBBJSON: @retroactive ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension RBBJSON: @retroactive ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .number(value)
    }
}

extension RBBJSON: @retroactive ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension RBBJSON: @retroactive ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: RBBJSON...) {
        self = .array(elements)
    }
}

extension RBBJSON: @retroactive ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .number(Double(value))
    }
}

extension RBBJSON: @retroactive ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, RBBJSON)...) {
        self = .object(Dictionary(elements) { a, _ in a })
    }
}
