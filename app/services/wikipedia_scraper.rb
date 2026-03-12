class WikipediaScraper
  include HTTParty

  def initialize
    @delay = 2 # seconds between requests
  end

  def scrape_politician_list(url)
    # Encode the URL to handle non-ASCII characters
    encoded_url = encode_url(url)
    response = self.class.get(encoded_url)
    return [] unless response.success?

    doc = Nokogiri::HTML(response.body)
    politicians = []

    # Extract base URL from the provided URL
    uri = URI.parse(encoded_url)
    base_url = "#{uri.scheme}://#{uri.host}"

    # This is a simplified example - actual implementation depends on Wikipedia structure
    doc.css('table.wikitable tr').each do |row|
      cells = row.css('td')
      next if cells.empty?

      name_cell = cells[0]
      link = name_cell.css('a').first

      if link
        politicians << {
          name: link.text.strip,
          wikipedia_url: "#{base_url}#{link['href']}"
        }
      end
    end

    politicians
  end

  def scrape_politician_page(url)
    sleep(@delay) # Rate limiting

    encoded_url = encode_url(url)
    response = self.class.get(encoded_url)
    return nil unless response.success?

    response.body
  rescue StandardError => e
    Rails.logger.error "Error scraping #{url}: #{e.message}"
    nil
  end

  private

  def encode_url(url)
    # Parse the URL and encode only the path component
    uri = URI.parse(url)
    uri.path = URI.encode_www_form_component(uri.path).gsub('%2F', '/')
    uri.to_s
  rescue URI::InvalidURIError
    # If the URL is already invalid, try to encode it completely
    URI::DEFAULT_PARSER.escape(url)
  end
end
