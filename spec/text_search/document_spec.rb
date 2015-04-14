require 'text_search'

describe TextSearch::Document do

  describe 'created with single vector' do
    before do
      @vector = TextSearch::Vector.new('table', 'name')
      @document = TextSearch::Document.new(@vector)
    end

    it 'has the correct vector' do
      expect(@document.vector).to eq(@vector)
    end

    it 'has the correct sql' do
      expect(@document.to_sql).to eq("to_tsvector('english', coalesce(table.name, ''))")
    end
  end

  describe 'created with multiple vectors' do
    before do
      @vector = [TextSearch::Vector.new('table', 'name'), TextSearch::Vector.new('table2', 'name2')]
      @document = TextSearch::Document.new(@vector)
    end

    it 'has the correct vector' do
      expect(@document.vector).to eq(@vector)
    end

    it 'has the correct sql' do
      expect(@document.to_sql).to eq("to_tsvector('english', coalesce(table.name, '')) || to_tsvector('english', coalesce(table2.name2, ''))")
    end
  end

  describe 'adding together documents' do
    before do
      @vector1 = TextSearch::Vector.new('table', 'name')
      document1 = TextSearch::Document.new(@vector1)

      @vector2 = TextSearch::Vector.new('table2', 'name2')
      document2 = TextSearch::Document.new(@vector2)

      @document = document1 + document2
    end

    it 'has the correct vector' do
      expect(@document.vector).to eq([@vector1, @vector2])
    end

    it 'has the correct sql' do
      expect(@document.to_sql).to eq("to_tsvector('english', coalesce(table.name, '')) || to_tsvector('english', coalesce(table2.name2, ''))")
    end

  end
end