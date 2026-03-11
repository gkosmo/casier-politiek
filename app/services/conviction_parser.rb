class ConvictionParser
  CONVICTION_KEYWORDS = [
    'convicted', 'condamné', 'condamnée', 'conviction', 'sentenced',
    'fraud', 'fraude', 'embezzlement', 'détournement',
    'corruption', 'guilty', 'coupable'
  ].freeze

  def initialize(html)
    @doc = Nokogiri::HTML(html)
  end

  def has_conviction?
    text = @doc.text.downcase
    CONVICTION_KEYWORDS.any? { |keyword| text.include?(keyword.downcase) }
  end

  def extract_convictions
    return [] unless has_conviction?

    # This is a simplified implementation
    # Real implementation would use more sophisticated parsing
    convictions = []

    # Look for paragraphs containing conviction keywords
    @doc.css('p').each do |paragraph|
      text = paragraph.text.downcase

      if CONVICTION_KEYWORDS.any? { |keyword| text.include?(keyword.downcase) }
        convictions << {
          description: paragraph.text.strip,
          offense_type: extract_offense_type(text),
          conviction_date: extract_date(text)
        }
      end
    end

    convictions.uniq
  end

  private

  def extract_offense_type(text)
    return 'fraud' if text.include?('fraud') || text.include?('fraude')
    return 'embezzlement' if text.include?('embezzlement') || text.include?('détournement')
    return 'corruption' if text.include?('corruption')

    'unknown'
  end

  def extract_date(text)
    # Simple year extraction
    match = text.match(/\b(19\d{2}|20\d{2})\b/)
    match ? Date.new(match[1].to_i, 1, 1) : nil
  rescue
    nil
  end
end
