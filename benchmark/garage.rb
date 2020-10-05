# frozen_string_literal: true

require 'garage'
require 'ostruct'


class AuthorResource
  include Garage::Representer

  property :id
  property :first_name
  property :last_name

  collection :books, selectable: true

  delegate :id, :first_name, :last_name, to: :@model

  attr_reader :model

  def initialize(model)
    @model = model
  end

  def books
    model.books.map { |book| BookResource.new(book) }
  end
end

class GenreResource
  include Garage::Representer

  property :id
  property :title
  property :description

  collection :books, selectable: true

  delegate :id, :title, :description, to: :@model

  attr_reader :model

  def initialize(model)
    @model = model
  end

  def books
    model.books.map { |book| BookResource.new(book) }
  end
end

class BookResource
  include Garage::Representer

  property :id
  property :title
  property :description
  property :published_at
  property :genre, selectable: true
  collection :authors, selectable: true

  delegate :id, :title, :description, :published_at, to: :@model

  attr_reader :model

  def initialize(model)
    @model = model
  end

  def genre
    GenreResource.new(model.genre)
  end

  def authors
    model.authors.map { |author| AuthorResource.new(author) }
  end
end

class BenchmarkResponder < ActionController::Responder
  include Garage::HypermediaResponder
end

def controller(selector)
  OpenStruct.new({
    :field_selector => selector,
    :params => { fields: 'fields' },
    :formats => [:json]
  })
end

def run!
  # Fixture
  resource = BookResource.new(DATA.sample)
  selector = Garage::NestedFieldQuery::Selector.build('__default__')
  responder = BenchmarkResponder.new(controller(selector), [resource])
  responder.transform(resource)
end

def run_many!
  resources = DATA.map {|book| BookResource.new(book) }
  selector = Garage::NestedFieldQuery::Selector.build('__default__')
  responder = BenchmarkResponder.new(controller(selector), resources)
  responder.transform(resources)
end

def run_include_all!
  resources = DATA.map {|book| BookResource.new(book) }
  selector = Garage::NestedFieldQuery::Selector.build('__default__,authors,genre')
  responder = BenchmarkResponder.new(controller(selector), resources)
  responder.transform(resources)
end

def run_include_deep!
  resources = DATA.map {|book| BookResource.new(book) }
  selector = Garage::NestedFieldQuery::Selector.build('__default__,authors[__default__,books[__default__,genre[__default__,books[__default__[authors,genre]]]]]')
  responder = BenchmarkResponder.new(controller(selector), resources)
  responder.transform(resources)
end
