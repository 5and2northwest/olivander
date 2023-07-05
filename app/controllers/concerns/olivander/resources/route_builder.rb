module Olivander
  module Resources
    class ResourceAction
      attr_accessor :sym, :action, :verb, :confirm, :turbo_frame, :collection, :controller, :crud_action, :show_in_form, :show_in_datatable, :no_route

      def initialize(sym, action: nil, controller: nil, verb: :get, confirm: false, turbo_frame: nil, collection: false, crud_action: false,
                     show_in_form: true, show_in_datatable: true, no_route: false)
        self.sym = sym
        self.action = action || sym
        self.controller = controller
        self.verb = verb
        self.confirm = confirm
        self.turbo_frame = turbo_frame
        self.collection = collection
        self.crud_action = crud_action
        self.show_in_form = show_in_form
        self.show_in_datatable = show_in_datatable
        self.no_route = no_route
      end
    end

    class RoutedResource
      attr_accessor :model, :actions

      def initialize(model, crud_actions)
        self.model = model
        self.actions = []
        crud_actions.each do |ca|
          actions << ResourceAction.new(ca, controller: model, crud_action: true)
        end
      end

      def crud_actions
        actions.select{ |x| x.crud_action }
      end

      def additional_actions
        actions.select{ |x| !x.crud_action }
      end

      def member_actions
        additional_actions.select{ |x| !x.collection }
      end

      def collection_actions
        additional_actions.select{ |x| x.collection }
      end

      def datatable_bulk_actions
        collection_actions.select{ |x| x.show_in_datatable }
      end

      def unpersisted_crud_actions
        allowed = %i[index new]
        crud_actions.select{ |x| allowed.include?(x.sym) }
      end

      def persisted_crud_actions
        allowed = %i[show edit destroy]
        crud_actions.select{ |x| allowed.include?(x.sym) }
      end
    end

    module RouteBuilder
      extend ActiveSupport::Concern

      DEFAULT_CRUD_ACTIONS = %i[index new create show edit update destroy]

      included do
        class_attribute :resources, default: {}
        class_attribute :current_resource
      end

      class_methods do
        def resource(model, only: DEFAULT_CRUD_ACTIONS, except: [], &block)
          self.current_resource = RoutedResource.new(model, DEFAULT_CRUD_ACTIONS & (only - except))
          yield if block_given?
          resources[model] = current_resource
          self.current_resource = nil
        end

        def action(sym, verb: :get, confirm: false, turbo_frame: nil, collection: false, show_in_datatable: true, show_in_form: true, no_route: false, controller: nil, action: nil)
          raise 'Must be invoked in a resource block' unless current_resource.present?

          controller ||= current_resource.model
          current_resource.actions << ResourceAction.new(
            sym, action: action, controller: controller, verb: verb, confirm: confirm, turbo_frame: turbo_frame, collection: collection,
            show_in_datatable: show_in_datatable, show_in_form: show_in_form, no_route: no_route
          )
        end

        def build_routes(mapper)
          build_resource_routes(mapper)
        end

        def build_resource_routes(mapper)
          resources.keys.each do |k|
            r = resources[k]
            mapper.resources r.model, only: r.crud_actions.map{ |ca| ca.action } do
              mapper.member do
                r.member_actions.each do |ma|
                  next if ma.no_route
                  if ma.confirm
                    mapper.get ma.action, action: "confirm_#{ma.action}"
                    mapper.post ma.action
                  else
                    mapper.send(ma.verb, ma.action)
                  end
                end
              end

              mapper.collection do
                r.collection_actions.each do |ba|
                  next if ba.no_route
                  if ba.confirm
                    mapper.get ba.action, action: "confirm_#{ba.action}"
                    mapper.post ba.action
                  else
                    mapper.send(ma.verb, ba.action)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
