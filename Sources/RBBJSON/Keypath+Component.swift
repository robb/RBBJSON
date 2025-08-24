import Foundation

extension JSON {
    @dynamicMemberLookup
    public struct Placeholder: Hashable {
        static var sentinel: Self {
            .init(values: ["__sentinel_value": .init()])
        }

        var values: [String: Self] = [:]

        init() {}

        init(values: [String: Self]) {
            self.values = values
        }

        public subscript(dynamicMember member: String) -> Self {
            get {
                values[member] ?? .init()
            }
            set {
                values[member] = newValue
            }
        }
    }
}

extension WritableKeyPath where Root == JSON.Placeholder, Value == JSON.Placeholder {
    var components: [String] {
        var placeholder = JSON.Placeholder()
        placeholder[keyPath: self] = .sentinel

        var result: [String] = []

        while placeholder != .sentinel {
            let key = placeholder.values.keys.first!
            result.append(key)

            placeholder = placeholder[dynamicMember: key]
        }

        return result
    }

    var lastComponentName: String? {
        components.last
    }
}

extension JSON.Placeholder {
    subscript(keyPathComponents keyPathComponents: some Collection<String>) -> JSON.Placeholder {
        get {
            if let head = keyPathComponents.first {
                self[dynamicMember: head][keyPathComponents: keyPathComponents.dropFirst()]
            } else {
                self
            }
        }
        set {
            if let head = keyPathComponents.first {
                self[dynamicMember: head][keyPathComponents: keyPathComponents.dropFirst()] = newValue
            } else {
                self = newValue
            }
        }
    }
}

extension JSON {
    subscript(placeholderKeyPath keyPath: WritableKeyPath<JSON.Placeholder, JSON.Placeholder>) -> Self {
        self[keyPath.components]
    }

    private subscript(keyPathComponents: some Collection<String>) -> Self {
        if keyPathComponents.isEmpty {
            self
        } else {
            self[keyPathComponents.first!][keyPathComponents.dropFirst()]
        }
    }
}
