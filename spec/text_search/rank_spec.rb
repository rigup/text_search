require 'text_search'

describe TextSearch::Rank do
  before do
    vector = TextSearch::Vector.new('table', 'name')
    @document = TextSearch::Document.new(vector)
    @query = TextSearch::Query.new('term')

    @rank = TextSearch::Rank.new(@document, @query)
  end

  it 'has the correct document' do
    expect(@rank.document).to eql(@document)
  end

  it 'has the correct query' do
    expect(@rank.query).to eql(@query)
  end

  it 'has the correct sql' do
    expect(@rank.to_sql).to eql("1 * ts_rank(to_tsvector('english', coalesce(table.name, '')), to_tsquery('english_no_stop_words', '''term'':*'))")
  end
end
