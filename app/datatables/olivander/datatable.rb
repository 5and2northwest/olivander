module Olivander
  class Datatable < Effective::Datatable
    def link_col(field, path, path_args)
      dsl_tool.col(field) do |r|
        args = [].tap do |arr|
          if path_args.is_a? Array
            path_args.each do |arg|
              arr << r.send(arg)
            end
          else
            arr << r.send(path_args)
          end
        end
        link_to r.send(field), send(path, args)
      end
    end
  end
end
