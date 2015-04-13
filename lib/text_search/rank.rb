module TextSearch
  class Rank
    def initialize(document, query, weight = 1)
      @document = document
      @query = query
      @weight = weight
    end

    def document
      @document
    end

    def query
      @query
    end

    def to_sql
      "#{@weight} * ts_rank(#{@document.to_sql}, #{@query.to_sql})"
    end
  end
end