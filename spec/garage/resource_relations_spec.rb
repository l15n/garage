require 'spec_helper'

describe Garage::ResourceRelations do
  let(:resource) do
    Class.new do
      include Garage::Representer
      include Garage::ResourceRelations
      property :id

      # FIXME: For the nested relations, look up the corresponding resource. Maybe even allow the resource class to be specified
      # For the tests to run, the `:nested` relations will need the corresponding Resource to be available.
      # In this spec, the existing resources just are CampaignResource
      #
      #
      # Possible improved interface
      #
      # relation: true
      # relation: { nested: true, name: user }
      #
      #
      property :user, relation: true
      property :post, selectable: true, relation: true

      property :category, selectable: true, relation: :nested
      collection :likes, selectable: true, relation: :nested

      # name
      property :campaign, as: :special_campaign, selectable: true, relation: true
      property :video, selectable: :method, relation: true
    end
  end

  describe ".relations(selector)" do
    let(:selector) { Garage::NestedFieldQuery::Selector.build(fields) }
    subject(:relations) { resource.relations(selector) }

    context "with default selector" do
      let(:fields) { "" }

      it "returns only default relations" do
        expect(relations).to match_array([:user])
      end
    end

    context "with explicit selector" do
      let(:fields) { "__default__,post" }

      it "returns default and selectable relations" do
        expect(relations).to match_array([:post, :user])
      end
    end

    context "when selector includes properties with :as (alias)" do
      let(:fields) { "special_campaign" }

      it "returns the property name as relation" do
        expect(relations).to eq([:campaign])
      end
    end

    context "when selector includes nested (property) definition" do
      let(:fields) { "category[posts]" }

      it "returns the nested relation" do
        expect(relations).to eq([{ category: [:posts]}])
      end
    end

    context "when selector includes nested (collection) definition" do
      let(:fields) { "likes[user]" }

      it "returns the nested relation" do
        expect(relations).to eq([{ likes: [:user]}])
      end
    end

    context "when selector contains nested definition with full selector" do
      let(:fields) { "likes[*]" }

      it "returns the nested relation" do
        expect(relations).to eq([{ likes: [:user]}])
      end
    end

    context "with full selector" do
      let(:fields) { "*" }

      it "returns all selectable relations with full nesting" do
        category_relation = { category: [:posts]  }
        likes_relation = { likes: [:user] }
        expect(relations).to match_array [:post, :campaign, :user, category_relation, likes_relation]
      end

      it "ignores selectable relations with non-boolean selectable" do
        expect(relations).to_not include(:video)
      end
    end
  end
end
