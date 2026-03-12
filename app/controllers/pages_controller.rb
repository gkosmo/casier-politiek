class PagesController < ApplicationController
  def home
    # React app will fetch data from API
  end

  def data
    politicians = Politician.includes(:convictions).limit(100)
    stats = {
      by_party: Conviction.joins(:politician).group('politicians.party').count,
      total_convictions: Conviction.count,
      total_politicians: Politician.joins(:convictions).distinct.count
    }

    render json: {
      politicians: politicians.as_json(include: { convictions: {except: [:created_at, :updated_at]} }),
      stats: stats
    }
  end
end
