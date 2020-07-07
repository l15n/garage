class CategoryResource
  include Garage::Representer
  include Garage::ResourceRelations

  collection :posts, relation: true

  def initialize(model)
    @model = model
  end
end
