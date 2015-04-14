class CreateParentAndChild < ActiveRecord::Migration
  def change
    create_table :parents do |t|
      t.string :value_1
      t.string :value_2
    end

    create_table :children do |t|
      t.string :value_1
      t.string :value_2

      t.references :parent
    end
  end
end
