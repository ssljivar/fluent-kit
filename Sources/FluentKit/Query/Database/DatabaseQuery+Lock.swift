extension DatabaseQuery {
    /// The row-locking mode to request for a read query.
    public enum Lock: Sendable {
        case update
        case share
    }
}

extension DatabaseQuery.Lock: CustomStringConvertible {
    public var description: String {
        switch self {
        case .update: "update"
        case .share: "share"
        }
    }
}
