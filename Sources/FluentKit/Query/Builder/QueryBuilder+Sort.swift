extension QueryBuilder {
    // MARK: Sort

    @discardableResult
    public func sort<Field>(
        _ field: KeyPath<Model, Field>,
        _ direction: DatabaseQuery.Sort.Direction = .ascending
    ) -> Self
        where
            Field: QueryableProperty,
            Field.Model == Model
    {
        self.sort(Model.path(for: field), direction)
    }

    @discardableResult
    public func sort<Field>(
        _ field: KeyPath<Model, GroupPropertyPath<Model, Field>>,
        _ direction: DatabaseQuery.Sort.Direction = .ascending
    ) -> Self
        where Field: QueryableProperty
    {
        self.sort(Model.path(for: field), direction)
    }

    @discardableResult
    public func sort(
        _ path: FieldKey,
        _ direction: DatabaseQuery.Sort.Direction = .ascending
    ) -> Self {
        self.sort([path], direction)
    }

    @discardableResult
    public func sort(
        _ path: [FieldKey],
        _ direction: DatabaseQuery.Sort.Direction = .ascending
    ) -> Self {
        self.sort(.extendedPath(path, schema: Model.schemaOrAlias, space: Model.spaceIfNotAliased), direction)
    }

    @discardableResult
    public func sort<Joined, Field>(
        _ joined: Joined.Type,
        _ field: KeyPath<Joined, Field>,
        _ direction: DatabaseQuery.Sort.Direction = .ascending,
        alias: String? = nil
    ) -> Self
        where
            Field: QueryableProperty,
            Field.Model == Joined,
            Joined: Schema
    {
        self.sort(Joined.self, Joined.path(for: field), direction, alias: alias)
    }
    
    @discardableResult
    public func sort<Joined>(
        _ model: Joined.Type,
        _ path: FieldKey,
        _ direction: DatabaseQuery.Sort.Direction = .ascending,
        alias: String? = nil
    ) -> Self
        where Joined: Schema
    {
        self.sort(Joined.self, [path], direction)
    }

    @discardableResult
    public func sort<Joined>(
        _ model: Joined.Type,
        _ path: [FieldKey],
        _ direction: DatabaseQuery.Sort.Direction = .ascending,
        alias: String? = nil
    ) -> Self
        where Joined: Schema
    {
        self.sort(.extendedPath(path, schema: Joined.schemaOrAlias, space: Joined.spaceIfNotAliased), direction)
    }

    @discardableResult
    public func sort(
        _ field: DatabaseQuery.Field,
        _ direction: DatabaseQuery.Sort.Direction
    ) -> Self {
        self.sort(.sort(field, direction))
    }

    @discardableResult
    public func sort(_ sort: DatabaseQuery.Sort) -> Self {
        self.query.sorts.append(sort)
        return self
    }
}
