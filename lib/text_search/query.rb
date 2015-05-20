module TextSearch
  class Query
    def initialize(query)
      query = query.gsub /['?\\:]/, ''
      @query = Array(query).map { |n| n.split(' ') }.flatten.map { |q| "'#{ActiveRecord::Base.connection.quote(q)}'" }
    end

    def query
      @query
    end

    def to_sql
      # to_tsquery('english', "'[query]':*")
      # [query] is in single qoutes to allow special characters
      # :* allows [query] to be a prefix for a term
      if @query.size == 0
        "to_tsquery('english', '')"
      else
        @query.map { |q| "to_tsquery('english', '#{q}:*')" }.join(' || ')
      end
    end
  end
end