class LikeResource
  include Garage::Representer
  include Garage::ResourceRelations

  property :user, relation: true

  def initialize(model)
    @model = model
  end
end
