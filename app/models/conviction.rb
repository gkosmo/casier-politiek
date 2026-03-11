class Conviction < ApplicationRecord
  belongs_to :politician

  validates :politician, presence: true
  validates :conviction_date, presence: true
  validates :offense_type, presence: true
  validates :appeal_status, presence: true
  validates :source_url, presence: true

  enum :appeal_status, {
    final: 'final',
    under_appeal: 'under_appeal',
    cassation: 'cassation'
  }
end
