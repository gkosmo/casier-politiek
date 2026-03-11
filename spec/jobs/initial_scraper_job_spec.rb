require 'rails_helper'

RSpec.describe InitialScraperJob, type: :job do
  describe '#perform' do
    it 'enqueues jobs for each politician' do
      politicians_data = [
        { name: 'Test MP', wikipedia_url: 'https://en.wikipedia.org/wiki/Test_MP' },
        { name: 'Another MP', wikipedia_url: 'https://en.wikipedia.org/wiki/Another_MP' }
      ]

      allow_any_instance_of(WikipediaScraper).to receive(:scrape_politician_list).and_return(politicians_data)

      expect {
        InitialScraperJob.perform_now
      }.to change { Politician.count }.by(2)
    end
  end
end
