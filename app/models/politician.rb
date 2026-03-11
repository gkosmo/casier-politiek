class Politician < ApplicationRecord
  has_many :convictions, dependent: :destroy

  validates :name, presence: true
  validates :party, presence: true
  validates :position, presence: true

  enum :position, {
    federal_mp: 'federal_mp',
    mep: 'mep'
  }

  def convictions_count
    convictions.count
  end

  # Ransack searchable attributes for ActiveAdmin
  def self.ransackable_attributes(auth_object = nil)
    ["name", "party", "position", "active", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["convictions"]
  end
end
