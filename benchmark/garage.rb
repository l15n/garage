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

class BenchmarkResponder < ActionController::Responder
  include Garage::HypermediaResponder
end

def controller
  @controller ||= OpenStruct.new({
    :field_selector => Garage::NestedFieldQuery::Selector.build('*'),
    :params => { fields: 'fields' },
    :formats => [:json]
  })
end

def run!
  # Fixture
  resource = BookResource.new(DATA.sample)
  responder = BenchmarkResponder.new(controller, [resource])
  responder.transform(resource)
end
