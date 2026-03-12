namespace :scraper do
  desc "Test Wikipedia scraping with a single politician"
  task test_single: :environment do
    # Test with a well-known Belgian politician
    test_url = "https://en.wikipedia.org/wiki/Charles_Michel"

    puts "Testing Wikipedia scraper..."
    puts "URL: #{test_url}"
    puts "-" * 80

    scraper = WikipediaScraper.new
    html = scraper.scrape_politician_page(test_url)

    if html
      puts "✓ Successfully fetched page (#{html.length} bytes)"

      parser = ConvictionParser.new(html)
      has_conviction = parser.has_conviction?

      puts "Has conviction keywords: #{has_conviction ? 'YES' : 'NO'}"

      if has_conviction
        convictions = parser.extract_convictions
        puts "Found #{convictions.length} potential conviction(s):"
        convictions.each_with_index do |conv, i|
          puts "\nConviction ##{i + 1}:"
          puts "  Offense: #{conv[:offense_type]}"
          puts "  Date: #{conv[:conviction_date]}"
          puts "  Description: #{conv[:description]}"
        end
      else
        puts "\nNo conviction keywords found in page content."
        puts "This is expected - most politicians don't have conviction info on Wikipedia."
      end
    else
      puts "✗ Failed to fetch page"
    end
  end

  desc "Test scraping politician list"
  task test_list: :environment do
    puts "Testing politician list scraping..."
    puts "-" * 80

    scraper = WikipediaScraper.new
    politicians = scraper.scrape_politician_list(
      "https://en.wikipedia.org/wiki/List_of_members_of_the_Federal_Parliament_of_Belgium"
    )

    puts "Found #{politicians.length} politicians"
    puts "\nFirst 5:"
    politicians.first(5).each_with_index do |pol, i|
      puts "#{i + 1}. #{pol[:name]}"
      puts "   URL: #{pol[:wikipedia_url]}"
    end
  end

  desc "Quick test with a French Wikipedia page"
  task test_french: :environment do
    # French Wikipedia is more likely to have info about Belgian politicians
    test_url = "https://fr.wikipedia.org/wiki/Charles_Michel"

    puts "Testing with French Wikipedia..."
    puts "URL: #{test_url}"
    puts "-" * 80

    scraper = WikipediaScraper.new
    html = scraper.scrape_politician_page(test_url)

    if html
      puts "✓ Successfully fetched page (#{html.length} bytes)"

      parser = ConvictionParser.new(html)
      has_conviction = parser.has_conviction?

      puts "Has conviction keywords: #{has_conviction ? 'YES' : 'NO'}"

      # Show sample of content
      doc = Nokogiri::HTML(html)
      text_sample = doc.text.gsub(/\s+/, ' ').strip[0..500]
      puts "\nSample content:"
      puts text_sample
    else
      puts "✗ Failed to fetch page"
    end
  end
end
