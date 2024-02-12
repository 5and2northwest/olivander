module Olivander
  module Resources
    module CrudController
      extend ActiveSupport::Concern

      included do
        include Effective::CrudController
        layout 'olivander/adminlte/main'

        def index
          if request.format == :json && params[:_type].present? && params[:_type] == 'query'
            index_search
          else
            super
          end
        end

        def index_search
          self.resources ||= resource_scope.all if resource_scope.respond_to?(:all)
          if resource_scope.respond_to?(:search_for)
            self.resources = self.resources.search_for(params[:term])
          else
            k = resources.klass
            like_term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:term])}%"
            fields = %w[name title description text].keep_if{ |field| k.respond_to?(field) }
            clauses = fields.map{ |field| "#{field} ilike '#{like_term}'" }.join(' or ')
            orders = fields.join(', ')
            self.resources = self.resources.where(clauses).order(orders) if clauses.length.positive?
          end
          self.resources = self.resources.limit(25)
        end

        def permitted_params
          params.fetch(resource_klass.name.underscore.gsub('/', '_').to_sym, {}).permit!
        end
      end
    end
  end
end
