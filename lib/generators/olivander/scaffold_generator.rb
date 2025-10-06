module Olivander
  class ScaffoldGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers

    argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"
    class_option :menu,
                 type: :boolean,
                 default: true,
                 desc: "Modify MenuBuilder to include menu item"

    source_root File.expand_path('templates/scaffold', __dir__)

    hook_for :orm, as: :model, required: true do |instance, controller|
      instance.invoke controller, [ instance.name ], instance.options.merge({ test_framework: false })
    end

    hook_for :datatable, type: :boolean, default: true

    hook_for :resource_controller do |instance, controller|
      instance.invoke controller, [ instance.name.pluralize ], instance.options.merge({ helper: false, test_framework: false, assets: false })
    end

    def create_views
      # template "views/_form.html.haml", File.join("app/views", controller_file_path, '_form.html.haml')
      # template "views/_model.html.haml", File.join("app/views", controller_file_path, "_#{file_name}.html.haml")
    end

    # Make an entry in \Rails routing file <tt>config/routes.rb</tt>
    #
    #   route "root 'welcome#index'"
    #   route "root 'admin#index'", namespace: :admin
    def handle_route
      return if options[:actions].present?

      use_route_builder = File.exist?(Rails.root.join("app/services/route_builder.rb"))
      if use_route_builder
        route_for_route_builder
      else
        route "resources :#{file_name.pluralize}", namespace: regular_class_path
      end
    end

    def handle_menu
      say_status :menu, "Handling menu option", :yellow
      return unless options[:menu]
    
      target = 'app/services/menu_builder.rb'
      unless File.exist?(target)
        say_status :error, "#{target} not found, skipping menu injection", :red
        return
      end
    
      # The exact line we want to insert (note trailing comma)
      new_line = <<~RUBY.indent(6)
            builder.build_menu_item(key: "#{file_name.pluralize}", url: builder.#{file_name.pluralize}_path),
      RUBY
    
      file_contents = File.read(target)
      # avoid inserting duplicates
      if file_contents.include?(new_line.strip)
        say_status :skip, "menu item already present in #{target}", :yellow
        return
      end
    
      # Insert before the closing bracket of the array (a line that only contains optional whitespace and `]`)
      inject_into_file target,
                       new_line,
                       before: /^\s*\]\s*$/m,
                       verbose: true,
                       force: false
    
      say_status :done, "Inserted menu item into #{target}", :green
    end

    private

    def route_for_route_builder
      route 'RouteBuilder.build_routes(self)'
      namespace = regular_class_path
      namespace = Array(namespace)
      routing_code = "resource :#{file_name.pluralize}, namespaces:[#{namespace.map{ |n| ":#{n}" }.join(', ')}]"
      namespace_pattern = namespace.each_with_index.reverse_each.reduce(nil) do |pattern, (name, i)|
        cummulative_margin = "\\#{i + 1}[ ]{2}"
        blank_or_indented_line = "^[ ]*\n|^#{cummulative_margin}.*\n"
        "(?:(?:#{blank_or_indented_line})*?^(#{cummulative_margin})namespace :#{name} do\n#{pattern})?"
      end.then do |pattern|
        /^([ ]*).+include Olivander::Resources::RouteBuilder*\n#{pattern}/
      end
      # routing_code = namespace.reverse.reduce(routing_code) do |code, name|
      #   "namespace :#{name} do\n#{rebase_indentation(code, 2)}end"
      # end

      log :route, routing_code

      target_file_name = "app/services/route_builder.rb"
      in_root do
        if namespace_match = match_file(target_file_name, namespace_pattern)
          base_indent, *, existing_block_indent = namespace_match.captures.compact.map(&:length)
          existing_line_pattern = /^[ ]{,#{existing_block_indent}}\S.+\n?/
          routing_code = rebase_indentation(routing_code, base_indent + 1).gsub(existing_line_pattern, "")
          namespace_pattern = /#{Regexp.escape namespace_match.to_s}/
        end

        inject_into_file target_file_name, routing_code, after: namespace_pattern, verbose: true, force: false

        if behavior == :revoke && namespace.any? && namespace_match
          empty_block_pattern = /(#{namespace_pattern})((?:\s*end\n){1,#{namespace.size}})/
          gsub_file target_file_name, empty_block_pattern, verbose: false, force: true do |matched|
            beginning, ending = empty_block_pattern.match(matched).captures
            ending.sub!(/\A\s*end\n/, "") while !ending.empty? && beginning.sub!(/^[ ]*namespace .+ do\n\s*\z/, "")
            beginning + ending
          end
        end
      end
    end
  end
end
