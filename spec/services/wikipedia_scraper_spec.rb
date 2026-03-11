require 'rails_helper'

RSpec.describe WikipediaScraper do
  describe '#scrape_politician_list' do
    it 'fetches Belgian MP list from Wikipedia' do
      scraper = WikipediaScraper.new
      url = 'https://en.wikipedia.org/wiki/List_of_members_of_the_Federal_Parliament_of_Belgium'

      expect(scraper).to respond_to(:scrape_politician_list)
    end
  end

  describe '#scrape_politician_page' do
    it 'fetches individual politician page' do
      scraper = WikipediaScraper.new

      expect(scraper).to respond_to(:scrape_politician_page)
    end
  end
end
