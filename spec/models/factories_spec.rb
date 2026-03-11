require 'rails_helper'

RSpec.describe 'Factories' do
  it 'has a valid politician factory' do
    expect(build(:politician)).to be_valid
  end

  it 'has a valid conviction factory' do
    expect(build(:conviction)).to be_valid
  end
end
