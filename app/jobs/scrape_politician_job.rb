class ScrapePoliticianJob < ApplicationJob
  queue_as :scraping

  def perform(politician_id)
    politician = Politician.find(politician_id)
    return unless politician.wikipedia_url.present?

    scraper = WikipediaScraper.new
    html = scraper.scrape_politician_page(politician.wikipedia_url)
    return unless html

    parser = ConvictionParser.new(html)
    return unless parser.has_conviction?

    convictions_data = parser.extract_convictions

    convictions_data.each do |conviction_data|
      next if conviction_data[:conviction_date].nil?

      politician.convictions.find_or_create_by(
        conviction_date: conviction_data[:conviction_date],
        description: conviction_data[:description]
      ) do |conviction|
        conviction.offense_type = conviction_data[:offense_type]
        conviction.appeal_status = 'final' # default
        conviction.source_url = politician.wikipedia_url
        conviction.verified = false
      end
    end

    Rails.logger.info "Scraped #{convictions_data.length} convictions for #{politician.name}"
  end
end
