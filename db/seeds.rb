# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create admin user for ActiveAdmin
AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
  admin.password = 'password'
  admin.password_confirmation = 'password'
end

puts "Created admin user: admin@example.com / password"

# Only create sample data in development/test environments
if Rails.env.development? || Rails.env.test?
  # Create sample politicians
  parties = ['N-VA', 'CD&V', 'Open VLD', 'sp.a', 'Groen', 'Vlaams Belang', 'PS', 'MR', 'Ecolo']
  offense_types = ['fraud', 'embezzlement', 'corruption', 'defamation', 'tax_evasion']

  20.times do
    politician = Politician.create!(
      name: Faker::Name.name,
      party: parties.sample,
      position: ['federal_mp', 'mep'].sample,
      photo_url: "https://i.pravatar.cc/150?img=#{rand(1..70)}",
      wikipedia_url: "https://en.wikipedia.org/wiki/#{Faker::Name.name.gsub(' ', '_')}",
      active: [true, false].sample,
      hemicycle_position: { x: rand(0.0..1.0), y: rand(0.0..1.0) }
    )

    # Create 1-3 convictions per politician
    rand(1..3).times do
      politician.convictions.create!(
        conviction_date: Faker::Date.between(from: '1985-01-01', to: '2025-12-31'),
        offense_type: offense_types.sample,
        sentence_prison: ["2 years suspended", "1 year", "6 months", nil].sample,
        sentence_fine: rand(1000..100000),
        sentence_ineligibility: ["5 years", "10 years", nil].sample,
        appeal_status: ['final', 'under_appeal', 'cassation'].sample,
        description: Faker::Lorem.paragraph,
        source_url: "https://en.wikipedia.org/wiki/#{Faker::Name.name.gsub(' ', '_')}",
        verified: [true, false].sample
      )
    end
  end

  puts "Created #{Politician.count} politicians with #{Conviction.count} convictions"
else
  puts "Production environment - skipping sample data generation"
end