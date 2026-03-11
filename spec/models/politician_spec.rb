require 'rails_helper'

RSpec.describe Politician, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:party) }
    it { should validate_presence_of(:position) }
  end

  describe 'associations' do
    # Skipping this test as Conviction model will be created in Task 5
    # it { should have_many(:convictions).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:position).with_values(federal_mp: 'federal_mp', mep: 'mep').backed_by_column_of_type(:string) }
  end
end
