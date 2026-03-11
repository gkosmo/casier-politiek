require 'rails_helper'

RSpec.describe ConvictionParser do
  describe '#parse' do
    let(:html_with_conviction) do
      <<-HTML
        <html>
          <body>
            <p>John Doe was convicted of fraud in 2020 and sentenced to 2 years in prison.</p>
          </body>
        </html>
      HTML
    end

    let(:html_without_conviction) do
      <<-HTML
        <html>
          <body>
            <p>Jane Smith is a politician from Belgium.</p>
          </body>
        </html>
      HTML
    end

    it 'detects conviction keywords in text' do
      parser = ConvictionParser.new(html_with_conviction)

      expect(parser.has_conviction?).to be true
    end

    it 'returns false when no conviction keywords found' do
      parser = ConvictionParser.new(html_without_conviction)

      expect(parser.has_conviction?).to be false
    end

    it 'extracts conviction data' do
      parser = ConvictionParser.new(html_with_conviction)
      convictions = parser.extract_convictions

      expect(convictions).to be_an(Array)
    end
  end
end
