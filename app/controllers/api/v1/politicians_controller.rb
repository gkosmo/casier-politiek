module Api
  module V1
    class PoliticiansController < ApplicationController
      def index
        politicians = Politician.includes(:convictions)

        politicians = politicians.where(party: params[:party]) if params[:party].present?
        politicians = politicians.where(position: params[:position]) if params[:position].present?
        politicians = politicians.where('name ILIKE ?', "%#{params[:search]}%") if params[:search].present?

        politicians = politicians.page(params[:page]).per(params[:per_page] || 50)

        render json: {
          politicians: politicians.as_json(
            methods: [:convictions_count],
            except: [:created_at, :updated_at]
          ),
          meta: pagination_meta(politicians)
        }
      end

      def show
        politician = Politician.includes(:convictions).find(params[:id])

        render json: {
          politician: politician.as_json(
            include: {
              convictions: {
                except: [:created_at, :updated_at]
              }
            },
            except: [:created_at, :updated_at]
          )
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
