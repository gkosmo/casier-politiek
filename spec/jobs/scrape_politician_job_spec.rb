require 'rails_helper'

RSpec.describe ScrapePoliticianJob, type: :job do
  describe '#perform' do
    let(:politician) { create(:politician, wikipedia_url: 'https://en.wikipedia.org/wiki/Test_Politician') }

    it 'scrapes conviction data for a politician' do
      html = '<html><body><p>Convicted of fraud in 2020.</p></body></html>'

      allow_any_instance_of(WikipediaScraper).to receive(:scrape_politician_page).and_return(html)

      expect {
        ScrapePoliticianJob.perform_now(politician.id)
      }.to change { politician.reload.convictions.count }
    end

    it 'does not create convictions if none found' do
      html = '<html><body><p>A clean politician.</p></body></html>'

      allow_any_instance_of(WikipediaScraper).to receive(:scrape_politician_page).and_return(html)

      expect {
        ScrapePoliticianJob.perform_now(politician.id)
      }.not_to change { Conviction.count }
    end
  end
end
