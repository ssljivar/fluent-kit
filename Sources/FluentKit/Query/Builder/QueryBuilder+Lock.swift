extension QueryBuilder {
    // MARK: Locking

    /// Requests an update lock for rows returned by this query.
    ///
    /// Locking support depends on the database dialect. Unsupported dialects may omit the lock,
    /// and row locks are meaningful when this query executes within a database transaction.
    /// This is intended for row-returning queries; database-specific restrictions, such as
    /// locking aggregate queries, still apply.
    @discardableResult
    public func forUpdate() -> Self {
        self.query.lock = .update
        return self
    }

    /// Requests a shared lock for rows returned by this query.
    ///
    /// Locking support depends on the database dialect. Unsupported dialects may omit the lock,
    /// and row locks are meaningful when this query executes within a database transaction.
    /// This is intended for row-returning queries; database-specific restrictions, such as
    /// locking aggregate queries, still apply.
    @discardableResult
    public func forShare() -> Self {
        self.query.lock = .share
        return self
    }
}
