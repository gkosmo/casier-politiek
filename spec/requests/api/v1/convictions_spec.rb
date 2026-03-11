require 'rails_helper'

RSpec.describe 'Api::V1::Convictions', type: :request do
  describe 'GET /api/v1/convictions' do
    let!(:politician1) { create(:politician, party: 'N-VA') }
    let!(:politician2) { create(:politician, party: 'CD&V') }
    let!(:conviction1) do
      create(
        :conviction,
        politician: politician1,
        offense_type: 'fraud',
        conviction_date: '2020-01-01',
        appeal_status: 'final'
      )
    end
    let!(:conviction2) do
      create(
        :conviction,
        politician: politician2,
        offense_type: 'embezzlement',
        conviction_date: '2015-06-15',
        appeal_status: 'under_appeal'
      )
    end
    let!(:conviction3) do
      create(
        :conviction,
        politician: politician1,
        offense_type: 'fraud',
        conviction_date: '2018-03-10',
        appeal_status: 'final'
      )
    end

    context 'without filters' do
      it 'returns all convictions with politician info' do
        get '/api/v1/convictions'

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(3)
        expect(json['convictions'][0]).to have_key('politician')
        expect(json['convictions'][0]['politician']).to have_key('name')
        expect(json['convictions'][0]['politician']).to have_key('party')
      end

      it 'returns pagination metadata' do
        get '/api/v1/convictions'

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json).to have_key('meta')
        expect(json['meta']).to have_key('current_page')
        expect(json['meta']).to have_key('total_count')
        expect(json['meta']).to have_key('total_pages')
      end
    end

    context 'with date_from filter' do
      it 'filters convictions after specified date' do
        get '/api/v1/convictions', params: { date_from: '2019-01-01' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(1)
        expect(json['convictions'][0]['id']).to eq(conviction1.id)
        expect(json['convictions'][0]['conviction_date']).to eq('2020-01-01')
      end
    end

    context 'with date_to filter' do
      it 'filters convictions before specified date' do
        get '/api/v1/convictions', params: { date_to: '2016-12-31' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(1)
        expect(json['convictions'][0]['id']).to eq(conviction2.id)
        expect(json['convictions'][0]['conviction_date']).to eq('2015-06-15')
      end
    end

    context 'with date range filters' do
      it 'filters by both date_from and date_to' do
        get '/api/v1/convictions',
            params: { date_from: '2018-01-01', date_to: '2020-12-31' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(2)
        conviction_ids = json['convictions'].map { |c| c['id'] }
        expect(conviction_ids).to include(conviction1.id)
        expect(conviction_ids).to include(conviction3.id)
        expect(conviction_ids).not_to include(conviction2.id)
      end
    end

    context 'with offense_type filter' do
      it 'filters by offense type' do
        get '/api/v1/convictions', params: { offense_type: 'fraud' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(2)
        json['convictions'].each do |conviction|
          expect(conviction['offense_type']).to eq('fraud')
        end
      end

      it 'returns empty results for non-existent offense type' do
        get '/api/v1/convictions', params: { offense_type: 'non_existent_offense' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(0)
      end
    end

    context 'with appeal_status filter' do
      it 'filters by appeal status' do
        get '/api/v1/convictions', params: { appeal_status: 'final' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(2)
        json['convictions'].each do |conviction|
          expect(conviction['appeal_status']).to eq('final')
        end
      end

      it 'filters by under_appeal status' do
        get '/api/v1/convictions', params: { appeal_status: 'under_appeal' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(1)
        expect(json['convictions'][0]['appeal_status']).to eq('under_appeal')
      end
    end

    context 'with party filter' do
      it 'filters by politician party' do
        get '/api/v1/convictions', params: { party: 'N-VA' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(2)
        json['convictions'].each do |conviction|
          expect(conviction['politician']['party']).to eq('N-VA')
        end
      end

      it 'returns convictions only from specified party' do
        get '/api/v1/convictions', params: { party: 'CD&V' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(1)
        expect(json['convictions'][0]['politician']['party']).to eq('CD&V')
      end
    end

    context 'with multiple filters combined' do
      it 'filters by party and offense_type' do
        get '/api/v1/convictions',
            params: { party: 'N-VA', offense_type: 'fraud' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(2)
        json['convictions'].each do |conviction|
          expect(conviction['politician']['party']).to eq('N-VA')
          expect(conviction['offense_type']).to eq('fraud')
        end
      end

      it 'filters by party, date range, and appeal_status' do
        get '/api/v1/convictions',
            params: {
              party: 'N-VA',
              date_from: '2019-01-01',
              date_to: '2021-12-31',
              appeal_status: 'final'
            }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(1)
        conviction = json['convictions'][0]
        expect(conviction['politician']['party']).to eq('N-VA')
        expect(conviction['appeal_status']).to eq('final')
        expect(conviction['conviction_date']).to eq('2020-01-01')
      end

      it 'filters by all available filters at once' do
        get '/api/v1/convictions',
            params: {
              party: 'N-VA',
              offense_type: 'fraud',
              date_from: '2018-01-01',
              date_to: '2020-12-31',
              appeal_status: 'final'
            }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(2)
        conviction_ids = json['convictions'].map { |c| c['id'] }
        expect(conviction_ids).to include(conviction1.id)
        expect(conviction_ids).to include(conviction3.id)
      end
    end

    context 'with pagination' do
      before do
        # Create additional convictions to test pagination
        10.times do
          create(
            :conviction,
            politician: politician1,
            offense_type: 'fraud',
            conviction_date: '2020-05-01',
            appeal_status: 'final'
          )
        end
      end

      it 'returns default page size' do
        get '/api/v1/convictions'

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to be <= 50
      end

      it 'supports custom per_page parameter' do
        get '/api/v1/convictions', params: { per_page: 5 }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(5)
      end

      it 'supports page parameter' do
        get '/api/v1/convictions', params: { per_page: 5, page: 2 }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['meta']['current_page']).to eq(2)
        expect(json['convictions'].length).to eq(5)
      end

      it 'tracks correct pagination metadata' do
        get '/api/v1/convictions', params: { per_page: 5 }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['meta']['current_page']).to eq(1)
        expect(json['meta']['total_count']).to eq(13)
        expect(json['meta']['total_pages']).to eq(3)
      end
    end

    context 'response format' do
      it 'excludes created_at and updated_at timestamps' do
        get '/api/v1/convictions'

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        json['convictions'].each do |conviction|
          expect(conviction).not_to have_key('created_at')
          expect(conviction).not_to have_key('updated_at')
        end
      end

      it 'includes all conviction attributes' do
        get '/api/v1/convictions'

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        conviction = json['convictions'][0]
        expect(conviction).to have_key('id')
        expect(conviction).to have_key('conviction_date')
        expect(conviction).to have_key('offense_type')
        expect(conviction).to have_key('appeal_status')
        expect(conviction).to have_key('sentence_prison')
        expect(conviction).to have_key('sentence_fine')
        expect(conviction).to have_key('sentence_ineligibility')
        expect(conviction).to have_key('description')
        expect(conviction).to have_key('source_url')
      end

      it 'includes essential politician fields' do
        get '/api/v1/convictions'

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        politician = json['convictions'][0]['politician']
        expect(politician).to have_key('id')
        expect(politician).to have_key('name')
        expect(politician).to have_key('party')
        expect(politician).to have_key('photo_url')
        expect(politician).to have_key('position')
      end
    end
  end
end
