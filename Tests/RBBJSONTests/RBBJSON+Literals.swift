import RBBJSON

extension RBBJSON: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

extension RBBJSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension RBBJSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .number(value)
    }
}

extension RBBJSON: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension RBBJSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: RBBJSON...) {
        self = .array(elements)
    }
}

extension RBBJSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .number(Double(value))
    }
}

extension RBBJSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, RBBJSON)...) {
        self = .object(Dictionary(elements) { a, _ in a })
    }
}
