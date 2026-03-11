module Api
  module V1
    class ConvictionsController < ApplicationController
      def index
        convictions = Conviction.includes(:politician)

        # Date range filters
        if params[:date_from].present?
          convictions = convictions.where('conviction_date >= ?', params[:date_from])
        end

        if params[:date_to].present?
          convictions = convictions.where('conviction_date <= ?', params[:date_to])
        end

        # Offense type filter
        if params[:offense_type].present?
          convictions = convictions.where(offense_type: params[:offense_type])
        end

        # Appeal status filter
        if params[:appeal_status].present?
          convictions = convictions.where(appeal_status: params[:appeal_status])
        end

        # Party filter (joins with politician)
        if params[:party].present?
          convictions = convictions.joins(:politician).where(politicians: { party: params[:party] })
        end

        # Pagination
        convictions = convictions.page(params[:page]).per(params[:per_page] || 50)

        render json: {
          convictions: convictions.as_json(
            include: {
              politician: {
                only: [:id, :name, :party, :photo_url, :position]
              }
            },
            except: [:created_at, :updated_at]
          ),
          meta: pagination_meta(convictions)
        }
      end

      private

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
