module Garage::ResourceRelations
  extend ActiveSupport::Concern

  module ClassMethods
    # Calculate relations to include to avoid N+1 queries.
    # Requires that property (collection) definitions set a :relation option
    # and assumes that the model can be derived from the property name
    #
    # e.g.
    # # Relationship of depth one
    # property :episode, relation: true
    # # Nested relationships
    # property :episode, relation: :nested
    #
    # selector - the Garage::NestedFieldQuery::Selector for the query.
    #
    # Returns array of relations that can be used with ActiveRecord::QueryMethods#includes
    def relations(selector)
      selected_relations(selector).map { |definition| relation(definition, selector) }.to_a
    end

    private

    def selected_relations(selector)
      representer_attrs.lazy.select { |definition|
        definition.options[:relation]
      }. select { |definition|
        handle_definition?(selector, definition)
      }
    end

    # Similar to Garage:Representer#handle_definition?, but as a class method
    def handle_definition?(selector, definition)
      if definition.requires_select?
        selector.includes?(definition.name) && definition.options[:selectable] == true
      else
        !selector.excludes?(definition.name)
      end
    end

    def relation(definition, selector)
      if definition.options[:relation] == :nested
        nested_relation(definition, selector)
      else
        real_name(definition)
      end
    end

    def nested_relation(definition, selector)
      child_relations = resource_class(definition).relations(selector[definition.name])
      if child_relations.blank?
        real_name(definition)
      else
        { real_name(definition) => child_relations }
      end
    rescue NameError => e
      # When property doesn't have a matching Resource
      real_name(definition)
    end

    def real_name(definition)
      definition.instance_variable_get("@name")
    end

    def resource_class(definition)
      model_class_name = real_name(definition).to_s.classify.demodulize.singularize
      model_class = model_class_name.constantize
      if model_class.is_a? Garage::Representer
        model_class
      else
        "#{model_class_name}Resource".constantize
      end
    end
  end
end
