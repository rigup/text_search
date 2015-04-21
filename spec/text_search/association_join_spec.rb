require 'text_search'

describe TextSearch::AssociationJoin do
  before do
    @association_join = TextSearch::AssociationJoin.new(Parent, :children, %w(value_1 value_2))
  end

  it 'has the correct sql' do
    expect(@association_join.to_sql).to eql("LEFT OUTER JOIN (SELECT children.parent_id as id, string_agg(children.value_1, ' ') as value_1, string_agg(children.value_2, ' ') as value_2 FROM \"parents\" INNER JOIN \"children\" ON \"children\".\"parent_id\" = \"parents\".\"id\" GROUP BY children.parent_id) children on children.id = parents.id")
  end
end