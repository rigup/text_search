require 'text_search'

describe TextSearch::ScopeOptions do

  describe 'parse hash options' do
    describe 'with single query term' do
      before do
        @options = TextSearch::ScopeOptions.new(Parent, {
            query: 'Search',
            against: {
                value_1: 1,
                value_2: 0.5
            }
        })
      end

      it 'should have the appropriate groupings' do
        vars = @options.instance_values
        query = "to_tsquery('english', '''Search'':*')"
        select = "1 * ts_rank(to_tsvector('english', coalesce(parents.value_1, '')), to_tsquery('english', '''Search'':*')) + 0.5 * ts_rank(to_tsvector('english', coalesce(parents.value_2, '')), to_tsquery('english', '''Search'':*'))"
        where = "(to_tsvector('english', coalesce(parents.value_1, '')) || to_tsvector('english', coalesce(parents.value_2, ''))) @@ (#{query})"

        expect(vars['query'].to_sql).to eq(query)
        expect(@options.send(:rank)).to eq(select)
        expect(@options.send(:where)).to eq(where)
      end
    end

    describe 'with multiple query terms' do
      before do
        @options = TextSearch::ScopeOptions.new(Parent, {
            query: 'Search Two',
            against: {
                value_1: 1,
                value_2: 0.5
            }
        })
      end

      it 'should have the appropriate groupings' do
        vars = @options.instance_values
        query = "to_tsquery('english', '''Search'':*') || to_tsquery('english', '''Two'':*')"
        select = "1 * ts_rank(to_tsvector('english', coalesce(parents.value_1, '')), #{query}) + 0.5 * ts_rank(to_tsvector('english', coalesce(parents.value_2, '')), #{query})"
        where = "(to_tsvector('english', coalesce(parents.value_1, '')) || to_tsvector('english', coalesce(parents.value_2, ''))) @@ (#{query})"

        expect(vars['query'].to_sql).to eq(query)
        expect(@options.send(:rank)).to eq(select)
        expect(@options.send(:where)).to eq(where)
      end
    end
  end

  describe 'parse array options' do
    before do
      @options = TextSearch::ScopeOptions.new(Parent, {
          query: 'Search',
          against: [:value_1, :value_2]
      })
    end

    it 'should have the appropriate groupings' do
      vars = @options.instance_values
      query = "to_tsquery('english', '''Search'':*')"
      select = "1 * ts_rank(to_tsvector('english', coalesce(parents.value_1, '')) || to_tsvector('english', coalesce(parents.value_2, '')), #{query})"
      where = "(to_tsvector('english', coalesce(parents.value_1, '')) || to_tsvector('english', coalesce(parents.value_2, ''))) @@ (#{query})"

      expect(vars['query'].to_sql).to eq(query)
      expect(@options.send(:rank)).to eq(select)
      expect(@options.send(:where)).to eq(where)
    end
  end

  describe 'parse with boost' do
    before do
      @options = TextSearch::ScopeOptions.new(Parent, {
          query: 'Search',
          against: [:value_1, :value_2],
          boost: 'some sql command'
      })
    end

    it 'should have the appropriate groupings' do
      vars = @options.instance_values
      query = "to_tsquery('english', '''Search'':*')"
      select = "((some sql command) + 1 * ts_rank(to_tsvector('english', coalesce(parents.value_1, '')) || to_tsvector('english', coalesce(parents.value_2, '')), #{query}))"
      where = "(to_tsvector('english', coalesce(parents.value_1, '')) || to_tsvector('english', coalesce(parents.value_2, ''))) @@ (#{query})"

      expect(vars['query'].to_sql).to eq(query)
      expect(@options.send(:rank)).to eq(select)
      expect(@options.send(:where)).to eq(where)
    end
  end

  describe 'test joins' do
    before do
      @options = TextSearch::ScopeOptions.new(Parent, {
          query: 'Search',
          against: [:value_1],
          associated_against: {
              children: [:value_1]
          }
      })
    end

    it 'should have the appropriate groupings' do
      vars = @options.instance_values
      joins = "LEFT OUTER JOIN (SELECT parents.id as id, string_agg(children.value_1, ' ') as value_1 FROM \"parents\" INNER JOIN \"children\" ON \"children\".\"parent_id\" = \"parents\".\"id\" GROUP BY parents.id) children on children.id = parents.id"
      query = "to_tsquery('english', '''Search'':*')"
      select = "1 * ts_rank(to_tsvector('english', coalesce(parents.value_1, '')) || to_tsvector('english', coalesce(children.value_1, '')), #{query})"
      where = "(to_tsvector('english', coalesce(parents.value_1, '')) || to_tsvector('english', coalesce(children.value_1, ''))) @@ (#{query})"

      expect(vars['joins'][0].to_sql).to eq(joins)
      expect(vars['query'].to_sql).to eq(query)
      expect(@options.send(:rank)).to eq(select)
      expect(@options.send(:where)).to eq(where)
    end
  end
end