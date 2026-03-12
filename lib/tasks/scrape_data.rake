namespace :scraper do
  desc "Scrape all Belgian politicians and their conviction data"
  task scrape_all: :environment do
    puts "=" * 80
    puts "Starting full scrape of Belgian politicians"
    puts "=" * 80
    puts ""

    scraper = WikipediaScraper.new

    # Wikipedia pages to scrape
    urls = [
      "https://en.wikipedia.org/wiki/List_of_members_of_the_Federal_Parliament_of_Belgium",
      "https://fr.wikipedia.org/wiki/Liste_des_députés_fédéraux_belges"
    ]

    all_politicians = []

    # Step 1: Scrape politician lists
    puts "STEP 1: Scraping politician lists..."
    puts "-" * 80

    urls.each do |url|
      puts "Fetching: #{url}"
      politicians = scraper.scrape_politician_list(url)
      puts "  Found #{politicians.length} politicians"
      all_politicians.concat(politicians)
    end

    # Remove duplicates by name
    all_politicians.uniq! { |p| p[:name] }
    puts ""
    puts "Total unique politicians found: #{all_politicians.length}"
    puts ""

    # Step 2: Create/update politicians in database
    puts "STEP 2: Creating politicians in database..."
    puts "-" * 80

    created_count = 0
    updated_count = 0

    all_politicians.each_with_index do |pol_data, index|
      politician = Politician.find_or_initialize_by(name: pol_data[:name])

      if politician.new_record?
        politician.wikipedia_url = pol_data[:wikipedia_url]
        politician.active = true
        politician.position = 'federal_mp'  # default
        politician.party = 'Unknown'  # Will be updated via admin panel
        politician.save!
        created_count += 1
        print "+"
      else
        # Update Wikipedia URL if changed
        if politician.wikipedia_url != pol_data[:wikipedia_url]
          politician.update(wikipedia_url: pol_data[:wikipedia_url])
          updated_count += 1
        end
        print "."
      end

      # Print progress every 50 politicians
      if (index + 1) % 50 == 0
        puts " #{index + 1}/#{all_politicians.length}"
      end
    end

    puts "" if all_politicians.length % 50 != 0
    puts ""
    puts "Created: #{created_count} politicians"
    puts "Updated: #{updated_count} politicians"
    puts "Total in database: #{Politician.count}"
    puts ""

    # Step 3: Scrape conviction data
    puts "STEP 3: Scraping conviction data from Wikipedia..."
    puts "-" * 80
    puts "This will take a while due to rate limiting..."
    puts ""

    politicians_with_convictions = 0
    total_convictions = 0
    errors = 0

    Politician.where(active: true).find_each.with_index do |politician, index|
      next unless politician.wikipedia_url.present?

      puts "[#{index + 1}/#{Politician.where(active: true).count}] Checking: #{politician.name}"

      begin
        # Scrape the politician's page
        html = scraper.scrape_politician_page(politician.wikipedia_url)

        if html
          parser = ConvictionParser.new(html)

          if parser.has_conviction?
            convictions_data = parser.extract_convictions

            if convictions_data.any?
              puts "  ✓ Found #{convictions_data.length} potential conviction(s)"
              politicians_with_convictions += 1

              # Create convictions
              convictions_data.each do |conv_data|
                conviction = politician.convictions.find_or_initialize_by(
                  description: conv_data[:description]
                )

                conviction.assign_attributes(
                  offense_type: conv_data[:offense_type],
                  conviction_date: conv_data[:conviction_date],
                  source_url: politician.wikipedia_url,
                  verified: false  # Needs manual verification
                )

                if conviction.save
                  total_convictions += 1
                  puts "    - Created conviction: #{conv_data[:offense_type]}"
                end
              end
            end
          else
            print "  - No conviction keywords found\n"
          end
        else
          puts "  ✗ Failed to fetch page"
          errors += 1
        end
      rescue StandardError => e
        puts "  ✗ Error: #{e.message}"
        errors += 1
      end
    end

    puts ""
    puts "=" * 80
    puts "SCRAPING COMPLETE"
    puts "=" * 80
    puts "Politicians scraped: #{Politician.where(active: true).count}"
    puts "Politicians with convictions: #{politicians_with_convictions}"
    puts "Total convictions found: #{total_convictions}"
    puts "Errors: #{errors}"
    puts ""
    puts "NOTE: All convictions are marked as 'unverified'."
    puts "Please review and verify them in the admin panel."
    puts "=" * 80
  end

  desc "Scrape convictions for a specific politician by ID"
  task :scrape_politician, [:politician_id] => :environment do |t, args|
    unless args[:politician_id]
      puts "Usage: rails scraper:scrape_politician[POLITICIAN_ID]"
      exit 1
    end

    politician = Politician.find(args[:politician_id])
    puts "Scraping convictions for: #{politician.name}"
    puts "URL: #{politician.wikipedia_url}"
    puts "-" * 80

    scraper = WikipediaScraper.new
    html = scraper.scrape_politician_page(politician.wikipedia_url)

    if html
      parser = ConvictionParser.new(html)

      if parser.has_conviction?
        convictions_data = parser.extract_convictions
        puts "Found #{convictions_data.length} potential conviction(s)"

        convictions_data.each do |conv_data|
          puts ""
          puts "Offense: #{conv_data[:offense_type]}"
          puts "Date: #{conv_data[:conviction_date]}"
          puts "Description: #{conv_data[:description][0..200]}..."

          conviction = politician.convictions.create!(
            offense_type: conv_data[:offense_type],
            conviction_date: conv_data[:conviction_date],
            description: conv_data[:description],
            source_url: politician.wikipedia_url,
            verified: false
          )

          puts "✓ Created conviction ##{conviction.id}"
        end
      else
        puts "No conviction keywords found"
      end
    else
      puts "Failed to fetch page"
    end
  end

  desc "Update all politicians to inactive (before re-scraping)"
  task mark_all_inactive: :environment do
    count = Politician.update_all(active: false)
    puts "Marked #{count} politicians as inactive"
  end
end
