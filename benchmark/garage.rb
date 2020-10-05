# frozen_string_literal: true

require 'garage'
require 'ostruct'

class BookResource
  include Garage::Representer

  property :id
  property :title
  property :description
  property :published_at
  # property :genre
  # collection :authors
  delegate :id, :title, :description, :published_at, :genre, to: :@model

  def initialize(model)
    @model = model
  end
end

def run!
  # Fixture
  responder_class = Class.new(ActionController::Responder) do
    include Garage::HypermediaResponder
  end

  controller = OpenStruct.new({
                                :field_selector => Garage::NestedFieldQuery::Selector.build('*'),
                                :params => { fields: 'fields' },
                                :formats => [:json]
                              })

  resource = BookResource.new(DATA.sample)
  responder = responder_class.new(controller, [resource])

  responder.transform(resource)
end
