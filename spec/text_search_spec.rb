require 'text_search'

describe TextSearch do
  before do
    @parent = Parent.create(value_1: 'parent_value_1', value_2: 'parent_value_2')
    @child_1 = Child.create(parent: @parent, value_1: 'child_1_value_1', value_2: 'child_1_value_2')
    @child_2 = Child.create(parent: @parent, value_1: 'child_2_value_1', value_2: 'child_2_value_2')

  end

  describe 'no association search' do
    it 'returns for first value' do
      scope = Parent.all
      expect(scope.no_children('parent_value_1').include? @parent).to eq(true)
    end

    it 'returns for second value' do
      scope = Parent.all
      expect(scope.no_children('parent_value_2').include? @parent).to eq(true)
    end

    it 'does not return for bogus value' do
      scope = Parent.all
      expect(scope.no_children('derenge').include? @parent).to eq(false)
    end

    describe 'multiple terms' do
      it do
        scope = Parent.all
        expect(scope.no_children('parent_value_1 parent_value_2').include? @parent).to eq(true)
      end
    end
  end

  describe 'association search' do
    it 'returns for first child' do
      scope = Parent.all
      expect(scope.children_equal('child_1_value_1').include? @parent).to eq(true)
    end

    it 'returns for second child' do
      scope = Parent.all
      expect(scope.children_equal('child_2_value_1').include? @parent).to eq(true)
    end

    it 'does not return for bogus value' do
      scope = Parent.all
      expect(scope.children_equal('parent_value_1').include? @parent).to eq(false)
    end
  end
end