require "spec_helper"

describe "Field loading API", type: :request do
  include RestApiSpecHelper
  include AuthenticatedContext

  let(:post_a) do
    FactoryBot.create(:post)
  end

  describe "GET /posts/:id" do
    let(:id) do
      post_a.id
    end

    let!(:comment) do
      FactoryBot.create(:comment, user: user, post: post_a)
    end

    context "with params[:fields] = nil" do
      it "returns default fields" do
        is_expected.to eq(200)
        expect(response.body).to be_json_as(
          id: Integer,
          title: String,
          _links: Hash,
        )
      end
    end

    context "with params[:fields] = '__default__,user'" do
      before do
        params[:fields] = "__default__,user"
      end

      it "returns default and user fields" do
        is_expected.to eq(200)
        expect(response.body).to be_json_as(
          id: Integer,
          title: String,
          user: Hash,
          _links: Hash,
        )
      end
    end

    context "with params[:fields] = '*'" do
      before do
        params[:fields] = "*"
      end

      it "returns all fields" do
        is_expected.to eq(200)
        expect(response.body).to be_json_as(
          id: Integer,
          title: String,
          label: String,
          user: Hash,
          comments: Array,
          _links: Hash,
        )
      end
    end

    context "with params[:fields] = 'id'" do
      before do
        params[:fields] = "id"
      end

      it "returns only id field" do
        is_expected.to eq(200)
        expect(response.body).to be_json_as(id: Integer)
      end
    end

    context "with params[:fields] = 'id,title,label'" do
      before do
        params[:fields] = "id,title,label"
      end

      it "returns only id and title fields" do
        is_expected.to eq(200)
        expect(response.body).to be_json_as(
          id: Integer,
          title: String,
          label: String
        )
      end
    end

    context "with params[:fields] = 'user[id]'" do
      before do
        params[:fields] = "user[id]"
      end

      it "returns only user's id field" do
        is_expected.to eq(200)
        expect(response.body).to be_json_as(
          user: {
            id: Integer,
          },
        )
      end
    end

    context "with params[:fields] = 'comments[__default__,post_owner]'" do
      before do
        params[:fields] = "comments[__default__,post_owner]"
      end

      it "returns only comments default & post_owner fields" do
        is_expected.to eq(200)
        expect(response.body).to be_json_as(
          comments: [
            {
              id: Integer,
              body: String,
              commenter: Hash,
              post_owner: Hash,
            },
          ],
        )
      end
    end

    context "with params[:fields] = 'comments[commenter[id],post_owner[id,name]]'" do
      before do
        params[:fields] = "comments[commenter[id],post_owner[id,name]]"
      end

      let(:post_a) do
        FactoryBot.create(:post, user: user)
      end

      let!(:comment) do
        FactoryBot.create(:comment, user: user, post: post_a)
      end

      it "returns different fields in commenter and post_owner" do
        is_expected.to eq(200)
        expect(response.body).to be_json_as(
          comments: [
            {
              commenter: {
                id: user.id,
              },
              post_owner: {
                id: user.id,
                name: user.name,
              },
            },
          ],
        )
      end
    end

    context "with params[:fields] = 'comments[*]'" do
      before do
        params[:fields] = "comments[*]"
      end

      it "returns only comments all fields" do
        is_expected.to eq(200)
        expect(response.body).to be_json_as(
          comments: [
            {
              id: Integer,
              body: String,
              commenter: Hash,
              post_owner: Hash,
            },
          ],
        )
      end
    end

    context "with params[:fields] = 'comments[commenter[id]]'" do
      before do
        params[:fields] = "comments[commenter[id]]"
      end

      it "returns only comments commenter id field" do
        is_expected.to eq(200)
        expect(response.body).to be_json_as(
          comments: [
            {
              commenter: {
                id: Integer,
              },
            },
          ],
        )
      end
    end
  end

  describe "GET /users/:user_id/posts" do
    before do
      FactoryBot.create(:post, user: user)
    end

    let(:user_id) do
      user.id
    end

    context "with caching" do
      it "caches response per params[:fields]" do
        is_expected.to eq(200)
        expect(response.body).to be_json_as([{ id: Integer, title: String, _links: Hash }])
        params[:fields] = "id"
        get path, params, env
        expect(response.body).to be_json_as([{ id: Integer }])
      end
    end

    context "with invalid params[:fields]" do
      before do
        params[:fields] = "[]"
      end
      it { is_expected.to eq(400) }
    end
  end
end
