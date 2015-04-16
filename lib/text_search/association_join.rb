module TextSearch
  class AssociationJoin

    def initialize(model, association, attributes)
      @model = model
      @alias = association.to_s
      @association = find_association(association, @model)
      @attributes = attributes
    end

    def to_sql
      options_as = @attributes.map { |attribute| "string_agg(#{@association.table_name}.#{attribute}, ' ') as #{attribute}" }.join ', '
      sql = @model.unscoped.joins(@alias.to_sym).select("#{primary_key} as id, #{options_as}").group(primary_key).to_sql
      outer_join(sql)
    end


    private
    def outer_join(sql)
      "LEFT OUTER JOIN (#{sql}) #{@alias} on #{@alias}.id = #{@model.table_name}.id"
    end


    def primary_key
      foreign_reflections = [ActiveRecord::Reflection::HasOneReflection,
                             ActiveRecord::Reflection::HasManyReflection,
                             ActiveRecord::Reflection::HasAndBelongsToManyReflection]
      if foreign_reflections.include? @association.class
        "#{@association.table_name}.#{@association.foreign_key}"
      else
        "#{@association.table_name}.id"
      end
    end

    # Changes a symbol into a class
    def symbol_to_constant_class(symbol, parent_class)
      name = symbol.to_s
      # If the classified version of the symbol is defined, then it has a model and can be made into a constant
      if Object.const_defined?(name.singularize.classify)
        name.singularize.classify.constantize
      else
        # If it isn't defined, this means that the attribute is a renamed version of a class
        find_association(symbol, parent_class).class_name.classify.constantize
      end
    end

    def find_association(symbol, parent_class)
      name = symbol.to_s
      parent_class.reflect_on_all_associations.each do |assoc|
        if assoc.name.to_s == name
          return assoc
        end
      end
    end
  end
end