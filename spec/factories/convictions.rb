FactoryBot.define do
  factory :conviction do
    association :politician
    conviction_date { Faker::Date.between(from: '1985-01-01', to: '2030-12-31') }
    offense_type { ['fraud', 'embezzlement', 'defamation', 'corruption', 'tax_evasion'].sample }
    sentence_prison { '2 years suspended' }
    sentence_fine { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    sentence_ineligibility { '5 years' }
    appeal_status { 'final' }
    description { Faker::Lorem.paragraph }
    source_url { Faker::Internet.url(host: 'wikipedia.org') }
    verified { false }

    trait :verified do
      verified { true }
    end

    trait :under_appeal do
      appeal_status { 'under_appeal' }
    end

    trait :cassation do
      appeal_status { 'cassation' }
    end
  end
end
