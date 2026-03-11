require 'rails_helper'

RSpec.describe 'Api::V1::Politicians', type: :request do
  describe 'GET /api/v1/politicians' do
    let!(:federal_mp) { create(:politician, :federal_mp, party: 'N-VA') }
    let!(:mep) { create(:politician, :mep, party: 'CD&V') }
    let!(:conviction) { create(:conviction, politician: federal_mp) }

    context 'without filters' do
      it 'returns all politicians' do
        get '/api/v1/politicians'

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['politicians'].length).to eq(2)
      end
    end

    context 'with party filter' do
      it 'filters by party' do
        get '/api/v1/politicians', params: { party: 'N-VA' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['politicians'].length).to eq(1)
        expect(json['politicians'][0]['party']).to eq('N-VA')
      end
    end

    context 'with position filter' do
      it 'filters by position' do
        get '/api/v1/politicians', params: { position: 'mep' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['politicians'].length).to eq(1)
        expect(json['politicians'][0]['position']).to eq('mep')
      end
    end

    context 'with search' do
      it 'searches by name' do
        get '/api/v1/politicians', params: { search: federal_mp.name }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['politicians'].length).to eq(1)
      end
    end

    it 'includes conviction count' do
      get '/api/v1/politicians'

      json = JSON.parse(response.body)
      politician_with_conviction = json['politicians'].find { |p| p['id'] == federal_mp.id }
      expect(politician_with_conviction['convictions_count']).to eq(1)
    end
  end

  describe 'GET /api/v1/politicians/:id' do
    let!(:politician) { create(:politician) }
    let!(:conviction1) { create(:conviction, politician: politician) }
    let!(:conviction2) { create(:conviction, politician: politician) }

    it 'returns politician with convictions' do
      get "/api/v1/politicians/#{politician.id}"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['politician']['id']).to eq(politician.id)
      expect(json['politician']['convictions'].length).to eq(2)
    end
  end
end
