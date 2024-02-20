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
            self.resources = k.all
            fields = %w[name title description text].keep_if{ |field| k.respond_to?(field) }
            unless params[:term].blank?
              like_term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:term])}%"
              clauses = fields.map{ |field| "#{field} ilike '#{like_term}'" }.join(' or ')
            end
            orders = fields.join(', ')
            self.resources = self.resources.where(clauses) if clauses.present? && clauses.length.positive?
            self.resources = self.resources.order(orders) if orders.length.positive?
          end
          self.resources = self.resources.limit(25)
        end

        def permitted_params
          params.fetch(resource_klass.name.underscore.gsub('/', '_').to_sym, {}).permit!
        end

        def respond_with_success(resource, action)
          return if (response.body.respond_to?(:length) && response.body.length > 0)

          if specific_redirect_path?(action)
            respond_to do |format|
              format.html do
                flash[:success] ||= resource_flash(:success, resource, action)
                redirect_to(resource_redirect_path(resource, action))
              end

              format.js do
                flash[:success] ||= resource_flash(:success, resource, action)

                if params[:_datatable_action]
                  redirect_to(resource_redirect_path(resource, action))
                else
                  render(
                    (template_present?(action) ? action : :member_action),
                    locals: { action: action, remote_form_redirect: resource_redirect_path(resource, action)}
                  )
                end
              end
            end
          elsif template_present?(action)
            respond_to do |format|
              format.html do
                flash.now[:success] ||= resource_flash(:success, resource, action)
                render(action) # action.html.haml
              end

              format.js do
                flash.now[:success] ||= resource_flash(:success, resource, action)
                render(action) # action.js.erb
              end

              format.turbo_stream do
              end
            end
          else # Default
            respond_to do |format|
              format.html do
                flash[:success] ||= resource_flash(:success, resource, action)
                redirect_to(resource_redirect_path(resource, action))
              end

              format.js do
                flash.now[:success] ||= resource_flash(:success, resource, action)
                render(:member_action, locals: { action: action })
              end

              format.turbo_stream do
              end
            end
          end
        end
      end
    end
  end
end
