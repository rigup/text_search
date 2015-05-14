module TextSearch
  class RankGroup
    def initialize(ranks = nil)
      @ranks = Array(ranks)
    end

    def self.create_from_weighted_hash(weight_vector_map, query)
      rankings = RankGroup.new
      weight_vector_map.each do |weight, vectors|
        document = TextSearch::Document.new(vectors)
        rankings << TextSearch::Rank.new(document, query, weight)
      end
      rankings
    end


    def <<(rank)
      @ranks << rank
    end

    def to_sql
      @ranks.map { |rank| rank.to_sql }.join(' + ')
    end

    def to_s
      @ranks.map { |rank| rank.to_s }.join(' || ')
    end

    def whole_document
      Array(@ranks).map { |ranking| ranking.document }.inject { |documents, document| documents + document }
    end
  end
end