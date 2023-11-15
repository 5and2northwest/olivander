resource = (@_effective_resource || Effective::Resource.new(controller_path))
@resources = instance_variable_get('@' + resource.plural_name)

json.array! @resources