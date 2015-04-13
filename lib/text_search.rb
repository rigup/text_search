require 'active_support/concern'
require 'text_search/scope_options'
require 'text_search/vector'
require 'text_search/document'
require 'text_search/query'
require 'text_search/rank'

module TextSearch
  extend ActiveSupport::Concern

  module ClassMethods
    def text_search_scope(name, options)
      options_proc = if options.respond_to? :call
                       options
                     else
                       lambda { |query| {:query => query}.merge(options) }
                     end
      method = lambda do |*args|
        ScopeOptions.new(self, options_proc.call(*args)).apply(self)
      end

      define_singleton_method name, &method
    end
  end
end