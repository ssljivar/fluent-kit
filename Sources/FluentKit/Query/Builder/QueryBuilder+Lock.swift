extension QueryBuilder {
    // MARK: Locking

    /// Acquires an update lock on the selected rows until the transaction ends.
    ///
    /// Use when the transaction reads a row to decide whether to update that same row.
    /// Conflicting row locks and mutations wait until the transaction ends. This clause is
    /// emitted only when the SQL dialect supports it.
    @discardableResult
    public func forUpdate() -> Self {
        self.query.lock = .update
        return self
    }

    /// Acquires a shared lock on the selected rows until the transaction ends.
    ///
    /// Use when the transaction relies on these rows remaining unchanged while it performs other
    /// work. Other shared locks may coexist while conflicting mutations wait until the transaction
    /// ends. This clause is emitted only when the SQL dialect supports it.
    @discardableResult
    public func forShare() -> Self {
        self.query.lock = .share
        return self
    }
}
