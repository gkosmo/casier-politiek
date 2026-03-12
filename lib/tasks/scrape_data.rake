namespace :scraper do
  desc "Scrape all Belgian politicians and their conviction data (1999-present from legislature lists)"
  task scrape_all: :environment do
    puts "=" * 80
    puts "Starting full scrape of Belgian politicians"
    puts "=" * 80
    puts ""
    puts "NOTE: This scrapes legislature lists from 1999-present."
    puts "For earlier periods (1985-1999), use: rails scraper:scrape_historical"
    puts ""

    scraper = WikipediaScraper.new

    # Wikipedia pages to scrape
    # Chamber of Representatives by legislature (1999-present)
    #
    # Coverage:
    # - 1999-2024: Comprehensive legislature-by-legislature lists available
    # - Pre-1999: Limited list pages, see scraper:scrape_historical task
    urls = [
      # Current members (mixed sources)
      "https://en.wikipedia.org/wiki/List_of_members_of_the_Federal_Parliament_of_Belgium",
      "https://fr.wikipedia.org/wiki/Liste_des_députés_fédéraux_belges",

      # Historical legislatures (Chamber of Representatives)
      "https://en.wikipedia.org/wiki/List_of_members_of_the_Chamber_of_Representatives_of_Belgium,_2019–2024",
      "https://en.wikipedia.org/wiki/List_of_members_of_the_Chamber_of_Representatives_of_Belgium,_2014–2019",
      "https://en.wikipedia.org/wiki/List_of_members_of_the_Chamber_of_Representatives_of_Belgium,_2010–2014",
      "https://en.wikipedia.org/wiki/List_of_members_of_the_Chamber_of_Representatives_of_Belgium,_2007–2010",
      "https://en.wikipedia.org/wiki/List_of_members_of_the_Chamber_of_Representatives_of_Belgium,_2003–2007",
      "https://en.wikipedia.org/wiki/List_of_members_of_the_Chamber_of_Representatives_of_Belgium,_1999–2003",

      # Federal Parliament lists (may include both chambers)
      "https://en.wikipedia.org/wiki/List_of_members_of_the_Federal_Parliament_of_Belgium,_2003–2007",

      # French Wikipedia equivalents (may have more data)
      "https://fr.wikipedia.org/wiki/Liste_des_députés_de_la_Chambre_des_représentants_de_Belgique_(2019-2024)",
      "https://fr.wikipedia.org/wiki/Liste_des_députés_de_la_Chambre_des_représentants_de_Belgique_(2014-2019)",
      "https://fr.wikipedia.org/wiki/Liste_des_députés_de_la_Chambre_des_représentants_de_Belgique_(2010-2014)"
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
                  conviction_date: conv_data[:conviction_date] || Date.new(2000, 1, 1), # Default if no date found
                  source_url: politician.wikipedia_url,
                  appeal_status: 'final', # Default to final, can be updated manually
                  verified: false  # Needs manual verification
                )

                if conviction.save
                  total_convictions += 1
                  puts "    - Created conviction: #{conv_data[:offense_type]}"
                else
                  puts "    ! Failed to save conviction: #{conviction.errors.full_messages.join(', ')}"
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
            conviction_date: conv_data[:conviction_date] || Date.new(2000, 1, 1),
            description: conv_data[:description],
            source_url: politician.wikipedia_url,
            appeal_status: 'final',
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

  desc "Scrape all Belgian politicians from Wikidata (comprehensive 1985-present)"
  task scrape_from_wikidata: :environment do
    puts "=" * 80
    puts "Scraping Belgian politicians from Wikidata (1985-present)"
    puts "=" * 80
    puts ""
    puts "Using Wikidata SPARQL to get comprehensive historical coverage"
    puts "This includes Chamber of Representatives and Senate members"
    puts ""

    wikidata_scraper = WikidataScraper.new

    puts "Fetching politicians from Wikidata..."
    politicians_data = wikidata_scraper.fetch_belgian_politicians(start_year: 1985)

    puts "Found #{politicians_data.length} politician records from Wikidata"
    puts ""

    # Group by name to handle multiple terms
    politicians_by_name = politicians_data.group_by { |p| p[:name] }
    unique_politicians = politicians_by_name.keys.length

    puts "Unique politicians: #{unique_politicians}"
    puts ""

    puts "STEP 1: Creating politicians in database..."
    puts "-" * 80

    created_count = 0
    updated_count = 0
    skipped_count = 0

    politicians_by_name.each_with_index do |(name, records), index|
      # Use the most recent record for party info
      latest_record = records.max_by { |r| r[:term_end] || Date.today }

      politician = Politician.find_or_initialize_by(name: name)

      if politician.new_record?
        politician.assign_attributes(
          party: latest_record[:party],
          wikipedia_url: latest_record[:wikipedia_url],
          active: records.any? { |r| r[:term_end].nil? || r[:term_end] >= Date.today },
          position: 'federal_mp'
        )

        if politician.save
          created_count += 1
          print "+"
        else
          skipped_count += 1
          print "!"
        end
      else
        # Update if we have better data
        updates = {}
        updates[:wikipedia_url] = latest_record[:wikipedia_url] if latest_record[:wikipedia_url].present? && politician.wikipedia_url.blank?
        updates[:party] = latest_record[:party] if latest_record[:party] != 'Unknown' && politician.party == 'Unknown'

        if updates.any?
          politician.update(updates)
          updated_count += 1
          print "."
        else
          print "."
        end
      end

      # Print progress every 50 politicians
      if (index + 1) % 50 == 0
        puts " #{index + 1}/#{unique_politicians}"
      end
    end

    puts "" if unique_politicians % 50 != 0
    puts ""
    puts "Created: #{created_count} politicians"
    puts "Updated: #{updated_count} politicians"
    puts "Skipped: #{skipped_count} politicians (validation errors)"
    puts "Total in database: #{Politician.count}"
    puts ""

    puts "=" * 80
    puts "Wikidata import complete!"
    puts "=" * 80
    puts ""
    puts "Next step: Run 'rails scraper:scrape_all' to fetch conviction data"
    puts "from Wikipedia pages for these politicians."
  end

  desc "Scrape historical politicians (alias for scrape_from_wikidata)"
  task scrape_historical: :environment do
    Rake::Task['scraper:scrape_from_wikidata'].invoke
  end
end
