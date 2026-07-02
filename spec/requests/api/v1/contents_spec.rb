require 'rails_helper'

RSpec.describe 'Api::V1::Contents', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:user_content) { create(:content, user: user, title: 'Owner Content') }
  let!(:other_content) { create(:content, user: other_user, title: 'Other Content') }

  let(:valid_headers) do
    token = JsonWebToken.encode(user_id: user.id)
    { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json' }
  end

  let(:invalid_headers) do
    { 'Authorization' => 'Bearer invalid_token', 'Content-Type' => 'application/json' }
  end

  describe 'GET /api/v1/content (index)' do
    it 'returns all contents without authentication' do
      get '/api/v1/content'
      expect(response).to have_http_status(200)
      
      json = JSON.parse(response.body)
      expect(json['data']).to be_an(Array)
      expect(json['data'].size).to eq(2)
      
      # Verify camelCase attributes in response
      first_item = json['data'].first
      expect(first_item).to have_key('id')
      expect(first_item).to have_key('type')
      expect(first_item['type']).to eq('content')
      expect(first_item['attributes']).to have_key('title')
      expect(first_item['attributes']).to have_key('body')
      expect(first_item['attributes']).to have_key('createdAt')
      expect(first_item['attributes']).to have_key('updatedAt')
    end
  end

  describe 'POST /api/v1/contents (create)' do
    let(:valid_params) { { title: 'New Title', body: 'New Body' }.to_json }
    let(:invalid_params) { { title: '', body: '' }.to_json }

    context 'with valid authentication' do
      it 'creates a new content' do
        expect {
          post '/api/v1/contents', params: valid_params, headers: valid_headers
        }.to change(Content, :count).by(1)

        expect(response).to have_http_status(201)
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['title']).to eq('New Title')
        expect(json['data']['attributes']['body']).to eq('New Body')
        expect(json['data']['attributes']).to have_key('createdAt')
      end

      it 'returns 422 for invalid parameters' do
        post '/api/v1/contents', params: invalid_params, headers: valid_headers
        expect(response).to have_http_status(422)
      end
    end

    context 'without valid authentication' do
      it 'returns 401 Unauthorized' do
        post '/api/v1/contents', params: valid_params, headers: invalid_headers
        expect(response).to have_http_status(401)
      end

      it 'returns 401 Unauthorized with no headers' do
        post '/api/v1/contents', params: valid_params
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'PUT /api/v1/contents/:id (update)' do
    let(:update_params) { { title: 'Updated Title', body: 'Updated Body' }.to_json }

    context 'when owner' do
      it 'updates the content' do
        put "/api/v1/contents/#{user_content.id}", params: update_params, headers: valid_headers
        expect(response).to have_http_status(200)
        
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['title']).to eq('Updated Title')
        expect(json['data']['attributes']['body']).to eq('Updated Body')
        expect(json['data']['attributes']).to have_key('updatedAt')
      end

      it 'returns 422 for invalid updates' do
        invalid_update = { title: '', body: '' }.to_json
        put "/api/v1/contents/#{user_content.id}", params: invalid_update, headers: valid_headers
        expect(response).to have_http_status(422)
      end
    end

    context 'when not owner' do
      it 'returns 403 Forbidden' do
        put "/api/v1/contents/#{other_content.id}", params: update_params, headers: valid_headers
        expect(response).to have_http_status(403)
      end
    end

    context 'without authentication' do
      it 'returns 401 Unauthorized' do
        put "/api/v1/contents/#{user_content.id}", params: update_params
        expect(response).to have_http_status(401)
      end
    end

    context 'when content not found' do
      it 'returns 404 Not Found' do
        put '/api/v1/contents/99999', params: update_params, headers: valid_headers
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'DELETE /api/v1/contents/:id (delete)' do
    context 'when owner' do
      it 'deletes the content' do
        expect {
          delete "/api/v1/contents/#{user_content.id}", headers: valid_headers
        }.to change(Content, :count).by(-1)

        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Deleted')
      end
    end

    context 'when not owner' do
      it 'returns 403 Forbidden and does not delete' do
        expect {
          delete "/api/v1/contents/#{other_content.id}", headers: valid_headers
        }.not_to change(Content, :count)

        expect(response).to have_http_status(403)
      end
    end

    context 'without authentication' do
      it 'returns 401 Unauthorized' do
        delete "/api/v1/contents/#{user_content.id}"
        expect(response).to have_http_status(401)
      end
    end

    context 'when content not found' do
      it 'returns 404 Not Found' do
        delete '/api/v1/contents/99999', headers: valid_headers
        expect(response).to have_http_status(404)
      end
    end
  end
end
