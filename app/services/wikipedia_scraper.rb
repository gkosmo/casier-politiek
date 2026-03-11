class WikipediaScraper
  include HTTParty
  base_uri 'en.wikipedia.org'

  def initialize
    @delay = 2 # seconds between requests
  end

  def scrape_politician_list(url)
    response = self.class.get(url)
    return [] unless response.success?

    doc = Nokogiri::HTML(response.body)
    politicians = []

    # This is a simplified example - actual implementation depends on Wikipedia structure
    doc.css('table.wikitable tr').each do |row|
      cells = row.css('td')
      next if cells.empty?

      name_cell = cells[0]
      link = name_cell.css('a').first

      if link
        politicians << {
          name: link.text.strip,
          wikipedia_url: "https://en.wikipedia.org#{link['href']}"
        }
      end
    end

    politicians
  end

  def scrape_politician_page(url)
    sleep(@delay) # Rate limiting

    response = self.class.get(url)
    return nil unless response.success?

    response.body
  end
end
