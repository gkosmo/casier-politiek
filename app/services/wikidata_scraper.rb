class WikidataScraper
  include HTTParty
  base_uri 'https://query.wikidata.org'

  # SPARQL query to get all Belgian federal parliament members since 1985
  # Includes: Chamber of Representatives and Senate members
  def fetch_belgian_politicians(start_year: 1985)
    query = <<~SPARQL
      SELECT DISTINCT ?person ?personLabel ?partyLabel ?startDate ?endDate ?wikipedia_en ?wikipedia_fr WHERE {
        # Person who held a position in Belgian federal parliament
        ?person p:P39 ?position_statement.

        # Position is either member of Chamber of Representatives or Belgian Senate
        ?position_statement ps:P39 ?position.
        VALUES ?position {
          wd:Q15705021  # member of the Chamber of Representatives of Belgium
          wd:Q18911991  # member of the Belgian Senate
        }

        # Get start and end dates if available
        OPTIONAL { ?position_statement pq:P580 ?startDate. }
        OPTIONAL { ?position_statement pq:P582 ?endDate. }

        # Filter for terms starting from #{start_year} or later
        FILTER(!BOUND(?startDate) || YEAR(?startDate) >= #{start_year})

        # Get political party if available
        OPTIONAL {
          ?person wdt:P102 ?party.
        }

        # Get Wikipedia links
        OPTIONAL {
          ?wikipedia_en schema:about ?person;
                       schema:isPartOf <https://en.wikipedia.org/>.
        }
        OPTIONAL {
          ?wikipedia_fr schema:about ?person;
                       schema:isPartOf <https://fr.wikipedia.org/>.
        }

        # Get labels in English
        SERVICE wikibase:label { bd:serviceParam wikibase:language "en,fr,nl,de". }
      }
      ORDER BY ?startDate
    SPARQL

    response = self.class.get('/sparql', {
      query: { query: query, format: 'json' },
      headers: {
        'User-Agent' => 'CasierPolBe/1.0 (https://github.com/yourproject; contact@example.com) Ruby/HTTParty',
        'Accept' => 'application/sparql-results+json'
      },
      timeout: 60
    })

    unless response.success?
      Rails.logger.error "Wikidata query failed: HTTP #{response.code}"
      Rails.logger.error response.body if response.body
      return []
    end

    parse_wikidata_response(response)
  end

  private

  def parse_wikidata_response(response)
    parsed = response.parsed_response

    # Safely extract bindings
    return [] unless parsed && parsed['results'] && parsed['results']['bindings']

    results = parsed['results']['bindings']
    politicians = []

    results.each do |result|
      # Extract data from SPARQL result
      name = result['personLabel']['value'] rescue nil
      party = result['partyLabel']['value'] rescue nil
      wikipedia_en = result['wikipedia_en']['value'] rescue nil
      wikipedia_fr = result['wikipedia_fr']['value'] rescue nil
      start_date = result['startDate']['value'] rescue nil
      end_date = result['endDate']['value'] rescue nil

      next unless name

      politicians << {
        name: name,
        party: party || 'Unknown',
        wikipedia_url: wikipedia_en || wikipedia_fr,
        term_start: parse_date(start_date),
        term_end: parse_date(end_date),
        source: 'wikidata'
      }
    end

    politicians
  end

  def parse_date(date_string)
    return nil unless date_string
    Date.parse(date_string)
  rescue ArgumentError
    nil
  end
end
