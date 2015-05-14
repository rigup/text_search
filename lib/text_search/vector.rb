module TextSearch
  class Vector
    def initialize(table, name)
      @table = table
      @name = name
    end

    def table
      @table
    end

    def name
      @name
    end

    def to_sql
      "to_tsvector('english', coalesce(#{@table}.#{@name}, ''))"
    end

    def to_s
      "coalesce(#{@table}.#{@name}, '')"
    end
  end
end