class InitialScraperJob < ApplicationJob
  queue_as :scraping

  BELGIAN_MP_LIST_URL = 'https://en.wikipedia.org/wiki/List_of_members_of_the_Federal_Parliament_of_Belgium'
  BELGIAN_MEP_LIST_URL = 'https://en.wikipedia.org/wiki/List_of_members_of_the_European_Parliament_for_Belgium,_2019–2024'

  def perform
    scraper = WikipediaScraper.new

    # Scrape Federal MPs
    Rails.logger.info "Scraping Belgian Federal MPs..."
    federal_mps = scraper.scrape_politician_list(BELGIAN_MP_LIST_URL)
    create_politicians(federal_mps, 'federal_mp')

    # Scrape MEPs
    Rails.logger.info "Scraping Belgian MEPs..."
    meps = scraper.scrape_politician_list(BELGIAN_MEP_LIST_URL)
    create_politicians(meps, 'mep')

    # Enqueue jobs to scrape each politician's page for convictions
    Politician.find_each do |politician|
      ScrapePoliticianJob.perform_later(politician.id)
    end

    Rails.logger.info "Initial scraping completed. #{Politician.count} politicians added."
  end

  private

  def create_politicians(politicians_data, position)
    politicians_data.each do |data|
      next if data[:name].blank?

      Politician.find_or_create_by(
        name: data[:name],
        wikipedia_url: data[:wikipedia_url]
      ) do |politician|
        politician.party = 'Unknown' # Will be updated manually
        politician.position = position
        politician.active = true
      end
    end
  end
end
