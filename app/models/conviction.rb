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

  # Ransack searchable attributes for ActiveAdmin
  def self.ransackable_attributes(auth_object = nil)
    ["conviction_date", "offense_type", "appeal_status", "verified", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["politician"]
  end
end
