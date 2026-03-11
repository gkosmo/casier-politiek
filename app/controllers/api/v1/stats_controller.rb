module Api
  module V1
    class StatsController < ApplicationController
      def index
        convictions = Conviction.includes(:politician)

        by_party = convictions.joins(:politician)
          .group('politicians.party')
          .count

        by_year = convictions
          .group("DATE_PART('year', conviction_date)")
          .count
          .transform_keys(&:to_i)

        by_offense_type = convictions
          .group(:offense_type)
          .count

        render json: {
          by_party: by_party,
          by_year: by_year,
          by_offense_type: by_offense_type,
          total_convictions: convictions.count,
          total_politicians: Politician.joins(:convictions).distinct.count
        }
      end
    end
  end
end
