require 'text_search'

describe TextSearch::RankGroup do
  before do
    @ranks = []
    @whole_document = nil
    2.times do |i|
      vector = TextSearch::Vector.new("table#{i}", "name#{i}")
      document = TextSearch::Document.new(vector)
      query = TextSearch::Query.new("term")

      @ranks << TextSearch::Rank.new(document, query, i + 1)
      @whole_document = if @whole_document == nil
                          document
                        else
                          @whole_document + document
                        end
    end

    @rank_group = TextSearch::RankGroup.new(@ranks)
  end

  it 'has the correct sql' do
    expect(@rank_group.to_sql).to eql("1 * ts_rank(to_tsvector('english', coalesce(table0.name0, '')), to_tsquery('english', '''term'':*')) + 2 * ts_rank(to_tsvector('english', coalesce(table1.name1, '')), to_tsquery('english', '''term'':*'))")
  end

  it 'has the whole document' do
    expect(@rank_group.whole_document.to_sql).to eql(@whole_document.to_sql)
  end

  it 'allows the adding of ranks' do
    @rank_group << @ranks[0]
    new_whole = @whole_document + @ranks[0].document
    expect(@rank_group.whole_document.to_sql).to eql(new_whole.to_sql)
  end

  describe 'can be made from a hash' do
    before do
      map = {}
      query = TextSearch::Query.new("term")
      2.times do |i|
        vector = TextSearch::Vector.new("table#{i}", "name#{i}")
        map[i + 1] = vector
      end
      @rank_group = TextSearch::RankGroup.create_from_weighted_hash(map, query)
    end

    it do
      expect(@rank_group.to_sql).to eql("1 * ts_rank(to_tsvector('english', coalesce(table0.name0, '')), to_tsquery('english', '''term'':*')) + 2 * ts_rank(to_tsvector('english', coalesce(table1.name1, '')), to_tsquery('english', '''term'':*'))")
    end

  end
end