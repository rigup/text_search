module TextSearch
  class Document
    def initialize(vector)
      @vector = vector
    end

    def vector
      @vector
    end

    def to_sql
      Array(@vector).map { |vector| vector.to_sql }.join(' || ')
    end

    def to_s
      Array(@vector).map { |vector| vector.to_s }.join(" || ' ' || ")
    end

    def +(other_document)
      Document.new(Array(@vector) + Array(other_document.vector))
    end

  end
end