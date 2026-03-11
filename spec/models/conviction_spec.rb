require 'rails_helper'

RSpec.describe Conviction, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:politician) }
    it { should validate_presence_of(:conviction_date) }
    it { should validate_presence_of(:offense_type) }
    it { should validate_presence_of(:appeal_status) }
    it { should validate_presence_of(:source_url) }
  end

  describe 'associations' do
    it { should belong_to(:politician) }
  end

  describe 'enums' do
    it do
      should define_enum_for(:appeal_status)
        .with_values(final: 'final', under_appeal: 'under_appeal', cassation: 'cassation')
        .backed_by_column_of_type(:string)
    end
  end
end
