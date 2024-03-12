module Olivander
  module Resources
    module CrudController
      extend ActiveSupport::Concern

      included do
        include Effective::CrudController
        layout 'olivander/adminlte/main'
        before_action :fix_date_params

        def index
          if request.format == :json && params[:_type].present? && params[:_type] == 'query'
            index_search
          else
            super
          end
        end

        def index_search
          self.resources ||= resource_scope.all if resource_scope.respond_to?(:all)
          index_term_search if params[:term].present?
          index_param_search
          if resources.order_values.size.zero? && resources.model.implicit_order_column.present?
            self.resources = resources.order(resources.model.implicit_order_column.to_sym)
          end
          self.resources = self.resources.limit(25)
        end

        def index_param_search
          params.each do |param|
            effective_resource.klass.columns.each do |col|
              next unless col.name == param[0] #&& !param[1].blank?

              self.resources = self.resources.where(param[0].to_sym => param[1])
            end
          end
        end

        def index_term_search
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

        def respond_with_error(resource, action)
          return if response.body.present?

          flash.delete(:success)
          flash.now[:danger] ||= resource_flash(:danger, resource, action)

          respond_to do |format|
            case action_name.to_sym
            when :create
              format.html { render :new }
            when :update
              format.html { render :edit }
            when :destroy
              format.html do
                redirect_flash
                redirect_to(resource_redirect_path(resource, action))
              end
            else
              if template_present?(action)
                format.html { render(action, locals: { action: action }) }
              elsif request.referer.to_s.end_with?('/edit')
                format.html { render :edit }
              elsif request.referer.to_s.end_with?('/new')
                format.html { render :new }
              else
                format.html do
                  redirect_flash
                  redirect_to(resource_redirect_path(resource, action))
                end
              end
            end

            format.js do
              view = template_present?(action) ? action : :member_action
              render(view, locals: { action: action }) # action.js.erb
            end

            format.turbo_stream do
            end
          end
        end

        def date_params
          []
        end

        def fix_date_params
          recurse_and_fix_date_params(params)
        end

        def recurse_and_fix_date_params(params)
          params.keys.each do |k|
            if params[k].is_a? ActionController::Parameters
              recurse_and_fix_date_params(params[k])
            else
              params[k] = rearrange_date_param(params[k]) if date_params.include?(k.to_sym)
            end
          end
        end

        def rearrange_date_param(value)
          return nil if value.blank?

          parts = value.split('/')
          "#{parts[2]}-#{parts[0]}-#{parts[1]}"
        end
      end
    end
  end
end
