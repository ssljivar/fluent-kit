import NIOConcurrencyHelpers

extension Fields {
    public typealias OptionalField<Value> = OptionalFieldProperty<Self, Value>
        where Value: Codable & Sendable
}

// MARK: Type

@propertyWrapper
public final class OptionalFieldProperty<Model, WrappedValue>: @unchecked Sendable
    where Model: FluentKit.Fields, WrappedValue: Codable & Sendable
{
    public let key: FieldKey
    var outputValue: WrappedValue??
    var inputValue: DatabaseQuery.Value?

    public var projectedValue: OptionalFieldProperty<Model, WrappedValue> {
        self
    }

    public var wrappedValue: WrappedValue? {
        get { self.value ?? nil }
        set { self.value = .some(newValue) }
    }

    public init(key: FieldKey) {
        self.key = key
    }
}

// MARK: Property

extension OptionalFieldProperty: AnyProperty { }

extension OptionalFieldProperty: Property {
    public var value: WrappedValue?? {
        get {
            if let value = self.inputValue {
                switch value {
                case .bind(let bind):
                    .some(bind as? WrappedValue)
                case .enumCase(let string):
                    .some(string as? WrappedValue)
                case .default:
                    fatalError("Cannot access default field for '\(Model.self).\(key)' before it is initialized or fetched")
                case .null:
                    .some(.none)
                default:
                    fatalError("Unexpected input value type for '\(Model.self).\(key)': \(value)")
                }
            } else if let value = self.outputValue {
                .some(value)
            } else {
                .none
            }
        }
        set {
            if let value = newValue {
                self.inputValue = value
                    .flatMap { .bind($0) }
                    ?? .null
            } else {
                self.inputValue = nil
            }
        }
    }
}

// MARK: Queryable

extension OptionalFieldProperty: AnyQueryableProperty {
    public var path: [FieldKey] {
        [self.key]
    }
}

extension OptionalFieldProperty: QueryableProperty { }

// MARK: Query-addressable

extension OptionalFieldProperty: AnyQueryAddressableProperty {
    public var anyQueryableProperty: any AnyQueryableProperty { self }
    public var queryablePath: [FieldKey] { self.path }
}

extension OptionalFieldProperty: QueryAddressableProperty {
    public var queryableProperty: OptionalFieldProperty<Model, WrappedValue> { self }
}

// MARK: Database

extension OptionalFieldProperty: AnyDatabaseProperty {
    public var keys: [FieldKey] {
        [self.key]
    }

    public func input(to input: any DatabaseInput) {
        if input.wantsUnmodifiedKeys {
            input.set(self.inputValue ?? self.outputValue.map { $0.map { .bind($0) } ?? .null } ?? .default, at: self.key)
        } else if let inputValue = self.inputValue {
            input.set(inputValue, at: self.key)
        }
    }

    public func output(from output: any DatabaseOutput) throws {
        if output.contains(self.key) {
            self.inputValue = nil
            do {
                if try output.decodeNil(self.key) {
                    self.outputValue = .some(nil)
                } else {
                    self.outputValue = try .some(output.decode(self.key, as: Value.self))
                }
            } catch {
                throw FluentError.invalidField(
                    name: self.key.description,
                    valueType: Value.self,
                    error: error
                )
            }
        }
    }
}

// MARK: Codable

extension OptionalFieldProperty: AnyCodableProperty {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.wrappedValue)
    }

    public func decode(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.value = nil
        } else {
            self.value = try container.decode(Value.self)
        }
    }
}
