module TextSearch
  class ScopeOptions
    def initialize(model, options)
      @model = model
      @joins = []
      @boost = options[:boost]
      @query = Query.new(options[:query])

      weight_vector_map = parse_options options

      # Create the pieces needed to make select and where commands
      @rankings = RankGroup.create_from_weighted_hash(weight_vector_map, @query)

      # Allow the user to add an arbitrary sql command to the beginning of the rank to boost results
      if options[:boost]
        @boost = "(#{options[:boost]})"
      end
    end

    def apply(scope)
      # Pull in all the relations needed to do the ranking
      @joins.each do |join|
        scope = scope.joins(join.to_sql)
      end

      # Order by highest rank
      scope.order('rank DESC').select("#{@model.table_name}.*").select("#{rank} AS rank").where(where)
    end

    private
    def rank
      rank = @rankings.to_sql
      if @boost.present?
        rank = "(#{@boost} + #{rank})"
      end
      rank
    end

    def where
      "((#{@rankings.whole_document.to_sql}) @@ #{@query.to_sql})"
    end

    def parse_options(options)
      opts = options[:against]
      bins = parse_vectors(@model.table_name, opts)

      associations = options[:associated_against]
      Array(associations).map do |association, association_options|
        @joins << AssociationJoin.new(@model, association, Array(association_options).map {|option, weight| option})
        bins = bins.merge(parse_vectors(association, association_options)) do |key, oldval, newval|
          (newval.is_a?(Array) ? (oldval + newval) : (oldval << newval)).uniq
        end
      end

      bins
    end

    def parse_vectors(table, options)
      bins = {}
      Array(options).map do |option, weight = 1|
        bins[weight] = bins[weight].to_a + [Vector.new(table, option)]
      end
      bins
    end
  end
end