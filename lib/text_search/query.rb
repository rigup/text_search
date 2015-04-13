module TextSearch
  class Query
    def initialize(query)
      @query = query
    end

    def query
      @query
    end

    def to_sql
      # to_tsquery('english', "'[query]':*")
      # [query] is in single qoutes to allow special characters
      # :* allows [query] to be a prefix for a term
      query = @query.split(' ').map { |q| "to_tsquery('english', '''#{q}'':*')" }.join(' || ')
      "(#{query})"
    end
  end
end