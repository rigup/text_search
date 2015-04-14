require 'text_search'

describe TextSearch::Vector do
  before do
    @vector = TextSearch::Vector.new('table', 'name')
  end

  it 'has the correct table' do
    expect(@vector.table).to eql('table')
  end

  it 'has the correct name' do
    expect(@vector.name).to eql('name')
  end

  it 'has the correct sql' do
    expect(@vector.to_sql).to eql("to_tsvector('english', coalesce(table.name, ''))")
  end
end