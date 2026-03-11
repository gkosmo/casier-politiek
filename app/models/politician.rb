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
end
