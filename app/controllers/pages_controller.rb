class PagesController < ApplicationController
  def home
    @politicians = Politician.includes(:convictions).limit(100)
    @stats = {
      by_party: Conviction.joins(:politician).group('politicians.party').count,
      total_convictions: Conviction.count,
      total_politicians: Politician.joins(:convictions).distinct.count
    }
  end
end
