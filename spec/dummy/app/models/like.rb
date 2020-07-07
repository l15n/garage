class Like < ActiveRecord::Base
  def to_resource(options = {})
    LikeResource.new(self, options)
  end
end
