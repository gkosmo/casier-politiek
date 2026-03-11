FactoryBot.define do
  factory :politician do
    name { Faker::Name.name }
    party { ['CD&V', 'N-VA', 'Open VLD', 'sp.a', 'Groen', 'Vlaams Belang', 'PVDA'].sample }
    photo_url { Faker::Internet.url }
    position { ['federal_mp', 'mep'].sample }
    wikipedia_url { Faker::Internet.url(host: 'wikipedia.org') }
    active { true }
    hemicycle_position { { x: rand(0.0..1.0), y: rand(0.0..1.0) } }

    trait :federal_mp do
      position { 'federal_mp' }
    end

    trait :mep do
      position { 'mep' }
    end

    trait :inactive do
      active { false }
    end
  end
end
