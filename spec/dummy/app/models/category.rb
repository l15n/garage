class Category < ActiveRecord::Base
  def to_resource(options = {})
    CategoryResource.new(self, options)
  end
end
