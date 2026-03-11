require 'rails_helper'

RSpec.describe 'Api::V1::Stats', type: :request do
  describe 'GET /api/v1/stats' do
    let!(:politician1) { create(:politician, party: 'N-VA') }
    let!(:politician2) { create(:politician, party: 'CD&V') }
    let!(:conviction1) { create(:conviction, politician: politician1, offense_type: 'fraud', conviction_date: '2020-01-01') }
    let!(:conviction2) { create(:conviction, politician: politician1, offense_type: 'embezzlement', conviction_date: '2021-01-01') }
    let!(:conviction3) { create(:conviction, politician: politician2, offense_type: 'fraud', conviction_date: '2020-06-01') }

    it 'returns aggregated statistics' do
      get '/api/v1/stats'

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)

      expect(json).to have_key('by_party')
      expect(json).to have_key('by_year')
      expect(json).to have_key('by_offense_type')

      expect(json['by_party']['N-VA']).to eq(2)
      expect(json['by_party']['CD&V']).to eq(1)

      expect(json['by_offense_type']['fraud']).to eq(2)
      expect(json['by_offense_type']['embezzlement']).to eq(1)
    end
  end
end
