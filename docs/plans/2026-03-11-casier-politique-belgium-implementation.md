# Casier Politique Belgium Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Belgian politician conviction tracking system with Rails API, Wikipedia scraping, and React hemicycle visualization.

**Architecture:** Rails 7.1+ backend with PostgreSQL, Sidekiq for background scraping, ActiveAdmin for curation, Superglue.js bridging to React frontend with D3.js visualization.

**Tech Stack:** Rails 7.1+, PostgreSQL, Sidekiq, Redis, ActiveAdmin, Superglue.js, React, D3.js, Nokogiri, HTTParty

---

## Task 1: Initialize Rails Application

**Files:**
- Create: Rails application structure
- Create: `.gitignore`
- Create: `Gemfile`

**Step 1: Create new Rails app (API + frontend)**

Run:
```bash
rails new . --database=postgresql --skip-test --css=tailwind
```

Expected: Rails 7.1+ application created in current directory

**Step 2: Update Gemfile with required gems**

Modify: `Gemfile`

Add after existing gems:
```ruby
# Admin interface
gem 'activeadmin'
gem 'devise'

# Background jobs
gem 'sidekiq'

# Scraping
gem 'nokogiri'
gem 'httparty'

# API
gem 'active_model_serializers'
gem 'rack-cors'
gem 'kaminari' # pagination

# Superglue
gem 'superglue', '~> 0.40'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-rails'
end

group :test do
  gem 'shoulda-matchers'
  gem 'database_cleaner-active_record'
  gem 'webmock'
  gem 'vcr'
end
```

**Step 3: Install gems**

Run:
```bash
bundle install
```

Expected: All gems installed successfully

**Step 4: Update .gitignore**

Modify: `.gitignore`

Add:
```
# Environment variables
.env
.env.*

# IDE
.vscode/
.idea/

# Mac
.DS_Store

# Coverage
coverage/

# Ignore master key for decrypting credentials and more.
/config/master.key
/config/credentials/*.key
```

**Step 5: Commit initial setup**

Run:
```bash
git add .
git commit -m "feat: initialize Rails application with required gems"
```

---

## Task 2: Configure Database

**Files:**
- Modify: `config/database.yml`
- Create database

**Step 1: Update database.yml**

Modify: `config/database.yml`

Replace development section:
```yaml
development:
  <<: *default
  database: casier_pol_be_development
  username: <%= ENV.fetch("DATABASE_USERNAME", "") %>
  password: <%= ENV.fetch("DATABASE_PASSWORD", "") %>
  host: <%= ENV.fetch("DATABASE_HOST", "localhost") %>
```

Replace test section:
```yaml
test:
  <<: *default
  database: casier_pol_be_test
  username: <%= ENV.fetch("DATABASE_USERNAME", "") %>
  password: <%= ENV.fetch("DATABASE_PASSWORD", "") %>
  host: <%= ENV.fetch("DATABASE_HOST", "localhost") %>
```

**Step 2: Create database**

Run:
```bash
rails db:create
```

Expected: Development and test databases created

**Step 3: Commit database configuration**

Run:
```bash
git add config/database.yml
git commit -m "feat: configure PostgreSQL database"
```

---

## Task 3: Setup RSpec

**Files:**
- Create: `spec/` directory structure
- Create: `spec/rails_helper.rb`
- Create: `spec/spec_helper.rb`

**Step 1: Install RSpec**

Run:
```bash
rails generate rspec:install
```

Expected: RSpec configuration files created

**Step 2: Configure RSpec with shoulda-matchers**

Modify: `spec/rails_helper.rb`

Add at the end before final `end`:
```ruby
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
```

**Step 3: Verify RSpec works**

Run:
```bash
bundle exec rspec
```

Expected: "0 examples, 0 failures"

**Step 4: Commit RSpec setup**

Run:
```bash
git add spec/
git commit -m "feat: setup RSpec testing framework"
```

---

## Task 4: Create Politician Model

**Files:**
- Create: `spec/models/politician_spec.rb`
- Create: Migration for politicians table
- Create: `app/models/politician.rb`

**Step 1: Write failing test for Politician model**

Create: `spec/models/politician_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe Politician, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:party) }
    it { should validate_presence_of(:position) }
  end

  describe 'associations' do
    it { should have_many(:convictions).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:position).with_values(federal_mp: 'federal_mp', mep: 'mep') }
  end
end
```

**Step 2: Run test to verify it fails**

Run:
```bash
bundle exec rspec spec/models/politician_spec.rb
```

Expected: FAIL - "uninitialized constant Politician"

**Step 3: Generate migration**

Run:
```bash
rails generate migration CreatePoliticians name:string party:string photo_url:string position:string wikipedia_url:string active:boolean hemicycle_position:jsonb
```

**Step 4: Update migration with constraints**

Modify: `db/migrate/XXXXXX_create_politicians.rb`

```ruby
class CreatePoliticians < ActiveRecord::Migration[7.1]
  def change
    create_table :politicians do |t|
      t.string :name, null: false
      t.string :party, null: false
      t.string :photo_url
      t.string :position, null: false
      t.string :wikipedia_url
      t.boolean :active, default: true
      t.jsonb :hemicycle_position

      t.timestamps
    end

    add_index :politicians, :name
    add_index :politicians, :party
    add_index :politicians, :position
  end
end
```

**Step 5: Run migration**

Run:
```bash
rails db:migrate
```

Expected: Migration successful

**Step 6: Create Politician model**

Create: `app/models/politician.rb`

```ruby
class Politician < ApplicationRecord
  has_many :convictions, dependent: :destroy

  validates :name, presence: true
  validates :party, presence: true
  validates :position, presence: true

  enum position: {
    federal_mp: 'federal_mp',
    mep: 'mep'
  }
end
```

**Step 7: Run test to verify it passes**

Run:
```bash
bundle exec rspec spec/models/politician_spec.rb
```

Expected: All tests pass

**Step 8: Commit Politician model**

Run:
```bash
git add app/models/politician.rb db/migrate/ db/schema.rb spec/models/politician_spec.rb
git commit -m "feat: add Politician model with validations"
```

---

## Task 5: Create Conviction Model

**Files:**
- Create: `spec/models/conviction_spec.rb`
- Create: Migration for convictions table
- Create: `app/models/conviction.rb`

**Step 1: Write failing test for Conviction model**

Create: `spec/models/conviction_spec.rb`

```ruby
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
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run:
```bash
bundle exec rspec spec/models/conviction_spec.rb
```

Expected: FAIL - "uninitialized constant Conviction"

**Step 3: Generate migration**

Run:
```bash
rails generate migration CreateConvictions politician:references conviction_date:date offense_type:string sentence_prison:string sentence_fine:decimal sentence_ineligibility:string appeal_status:string description:text source_url:string verified:boolean
```

**Step 4: Update migration with constraints**

Modify: `db/migrate/XXXXXX_create_convictions.rb`

```ruby
class CreateConvictions < ActiveRecord::Migration[7.1]
  def change
    create_table :convictions do |t|
      t.references :politician, null: false, foreign_key: true
      t.date :conviction_date, null: false
      t.string :offense_type, null: false
      t.string :sentence_prison
      t.decimal :sentence_fine, precision: 10, scale: 2
      t.string :sentence_ineligibility
      t.string :appeal_status, null: false
      t.text :description
      t.string :source_url, null: false
      t.boolean :verified, default: false

      t.timestamps
    end

    add_index :convictions, :politician_id
    add_index :convictions, :conviction_date
    add_index :convictions, :offense_type
    add_index :convictions, :appeal_status
  end
end
```

**Step 5: Run migration**

Run:
```bash
rails db:migrate
```

Expected: Migration successful

**Step 6: Create Conviction model**

Create: `app/models/conviction.rb`

```ruby
class Conviction < ApplicationRecord
  belongs_to :politician

  validates :politician, presence: true
  validates :conviction_date, presence: true
  validates :offense_type, presence: true
  validates :appeal_status, presence: true
  validates :source_url, presence: true

  enum appeal_status: {
    final: 'final',
    under_appeal: 'under_appeal',
    cassation: 'cassation'
  }
end
```

**Step 7: Run test to verify it passes**

Run:
```bash
bundle exec rspec spec/models/conviction_spec.rb
```

Expected: All tests pass

**Step 8: Commit Conviction model**

Run:
```bash
git add app/models/conviction.rb db/migrate/ db/schema.rb spec/models/conviction_spec.rb
git commit -m "feat: add Conviction model with validations and associations"
```

---

## Task 6: Create Factory Bot Factories

**Files:**
- Create: `spec/factories/politicians.rb`
- Create: `spec/factories/convictions.rb`

**Step 1: Create Politician factory**

Create: `spec/factories/politicians.rb`

```ruby
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
```

**Step 2: Create Conviction factory**

Create: `spec/factories/convictions.rb`

```ruby
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
```

**Step 3: Test factories work**

Create: `spec/models/factories_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe 'Factories' do
  it 'has a valid politician factory' do
    expect(build(:politician)).to be_valid
  end

  it 'has a valid conviction factory' do
    expect(build(:conviction)).to be_valid
  end
end
```

**Step 4: Run test to verify factories work**

Run:
```bash
bundle exec rspec spec/models/factories_spec.rb
```

Expected: All tests pass

**Step 5: Commit factories**

Run:
```bash
git add spec/factories/
git commit -m "feat: add FactoryBot factories for testing"
```

---

## Task 7: Setup ActiveAdmin

**Files:**
- Create: ActiveAdmin configuration
- Create: `app/admin/politicians.rb`
- Create: `app/admin/convictions.rb`

**Step 1: Install ActiveAdmin**

Run:
```bash
rails generate active_admin:install
```

Expected: ActiveAdmin installed, Devise installed, admin_users migration created

**Step 2: Run migrations**

Run:
```bash
rails db:migrate
```

Expected: AdminUser table created

**Step 3: Create ActiveAdmin resource for Politicians**

Create: `app/admin/politicians.rb`

```ruby
ActiveAdmin.register Politician do
  permit_params :name, :party, :photo_url, :position, :wikipedia_url, :active, :hemicycle_position

  index do
    selectable_column
    id_column
    column :name
    column :party
    column :position
    column :active
    column :created_at
    actions
  end

  filter :name
  filter :party
  filter :position
  filter :active
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :party
      f.input :photo_url
      f.input :position, as: :select, collection: Politician.positions.keys
      f.input :wikipedia_url
      f.input :active
      f.input :hemicycle_position, as: :text, placeholder: '{"x": 0.5, "y": 0.5}'
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :party
      row :photo_url do |p|
        image_tag p.photo_url, size: '100x100' if p.photo_url.present?
      end
      row :position
      row :wikipedia_url do |p|
        link_to 'Wikipedia', p.wikipedia_url, target: '_blank' if p.wikipedia_url.present?
      end
      row :active
      row :hemicycle_position
      row :created_at
      row :updated_at
    end

    panel 'Convictions' do
      table_for politician.convictions do
        column :conviction_date
        column :offense_type
        column :appeal_status
        column :verified
        column 'Actions' do |conviction|
          link_to 'View', admin_conviction_path(conviction)
        end
      end
    end
  end
end
```

**Step 4: Create ActiveAdmin resource for Convictions**

Create: `app/admin/convictions.rb`

```ruby
ActiveAdmin.register Conviction do
  permit_params :politician_id, :conviction_date, :offense_type, :sentence_prison,
                :sentence_fine, :sentence_ineligibility, :appeal_status, :description,
                :source_url, :verified

  index do
    selectable_column
    id_column
    column :politician
    column :conviction_date
    column :offense_type
    column :appeal_status
    column :verified
    column :created_at
    actions
  end

  filter :politician
  filter :conviction_date
  filter :offense_type
  filter :appeal_status
  filter :verified
  filter :created_at

  form do |f|
    f.inputs do
      f.input :politician, as: :select, collection: Politician.all.map { |p| [p.name, p.id] }
      f.input :conviction_date, as: :datepicker
      f.input :offense_type
      f.input :sentence_prison
      f.input :sentence_fine
      f.input :sentence_ineligibility
      f.input :appeal_status, as: :select, collection: Conviction.appeal_statuses.keys
      f.input :description
      f.input :source_url
      f.input :verified
    end
    f.actions
  end

  show do
    attributes_table do
      row :politician
      row :conviction_date
      row :offense_type
      row :sentence_prison
      row :sentence_fine
      row :sentence_ineligibility
      row :appeal_status
      row :description
      row :source_url do |c|
        link_to 'Source', c.source_url, target: '_blank'
      end
      row :verified
      row :created_at
      row :updated_at
    end
  end
end
```

**Step 5: Commit ActiveAdmin setup**

Run:
```bash
git add app/admin/ db/migrate/ db/schema.rb config/initializers/active_admin.rb
git commit -m "feat: setup ActiveAdmin for Politicians and Convictions"
```

---

## Task 8: Create API Politicians Controller

**Files:**
- Create: `spec/requests/api/v1/politicians_spec.rb`
- Create: `app/controllers/api/v1/politicians_controller.rb`
- Create: `app/serializers/politician_serializer.rb`
- Modify: `config/routes.rb`

**Step 1: Write failing test for Politicians API**

Create: `spec/requests/api/v1/politicians_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe 'Api::V1::Politicians', type: :request do
  describe 'GET /api/v1/politicians' do
    let!(:federal_mp) { create(:politician, :federal_mp, party: 'N-VA') }
    let!(:mep) { create(:politician, :mep, party: 'CD&V') }
    let!(:conviction) { create(:conviction, politician: federal_mp) }

    context 'without filters' do
      it 'returns all politicians' do
        get '/api/v1/politicians'

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['politicians'].length).to eq(2)
      end
    end

    context 'with party filter' do
      it 'filters by party' do
        get '/api/v1/politicians', params: { party: 'N-VA' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['politicians'].length).to eq(1)
        expect(json['politicians'][0]['party']).to eq('N-VA')
      end
    end

    context 'with position filter' do
      it 'filters by position' do
        get '/api/v1/politicians', params: { position: 'mep' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['politicians'].length).to eq(1)
        expect(json['politicians'][0]['position']).to eq('mep')
      end
    end

    context 'with search' do
      it 'searches by name' do
        get '/api/v1/politicians', params: { search: federal_mp.name }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['politicians'].length).to eq(1)
      end
    end

    it 'includes conviction count' do
      get '/api/v1/politicians'

      json = JSON.parse(response.body)
      politician_with_conviction = json['politicians'].find { |p| p['id'] == federal_mp.id }
      expect(politician_with_conviction['convictions_count']).to eq(1)
    end
  end

  describe 'GET /api/v1/politicians/:id' do
    let!(:politician) { create(:politician) }
    let!(:conviction1) { create(:conviction, politician: politician) }
    let!(:conviction2) { create(:conviction, politician: politician) }

    it 'returns politician with convictions' do
      get "/api/v1/politicians/#{politician.id}"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['politician']['id']).to eq(politician.id)
      expect(json['politician']['convictions'].length).to eq(2)
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run:
```bash
bundle exec rspec spec/requests/api/v1/politicians_spec.rb
```

Expected: FAIL - "No route matches"

**Step 3: Add routes**

Modify: `config/routes.rb`

Add inside `Rails.application.routes.draw do`:
```ruby
  namespace :api do
    namespace :v1 do
      resources :politicians, only: [:index, :show]
      resources :convictions, only: [:index]
      get 'stats', to: 'stats#index'
    end
  end
```

**Step 4: Create Politicians controller**

Create: `app/controllers/api/v1/politicians_controller.rb`

```ruby
module Api
  module V1
    class PoliticiansController < ApplicationController
      def index
        politicians = Politician.includes(:convictions)

        politicians = politicians.where(party: params[:party]) if params[:party].present?
        politicians = politicians.where(position: params[:position]) if params[:position].present?
        politicians = politicians.where('name ILIKE ?', "%#{params[:search]}%") if params[:search].present?

        politicians = politicians.page(params[:page]).per(params[:per_page] || 50)

        render json: {
          politicians: politicians.as_json(
            methods: [:convictions_count],
            except: [:created_at, :updated_at]
          ),
          meta: pagination_meta(politicians)
        }
      end

      def show
        politician = Politician.includes(:convictions).find(params[:id])

        render json: {
          politician: politician.as_json(
            include: {
              convictions: {
                except: [:created_at, :updated_at]
              }
            },
            except: [:created_at, :updated_at]
          )
        }
      end

      private

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
```

**Step 5: Add convictions_count method to Politician model**

Modify: `app/models/politician.rb`

Add method:
```ruby
  def convictions_count
    convictions.count
  end
```

**Step 6: Run test to verify it passes**

Run:
```bash
bundle exec rspec spec/requests/api/v1/politicians_spec.rb
```

Expected: All tests pass

**Step 7: Commit Politicians API**

Run:
```bash
git add app/controllers/api/v1/politicians_controller.rb app/models/politician.rb config/routes.rb spec/requests/api/v1/politicians_spec.rb
git commit -m "feat: add Politicians API with filtering and pagination"
```

---

## Task 9: Create API Convictions Controller

**Files:**
- Create: `spec/requests/api/v1/convictions_spec.rb`
- Create: `app/controllers/api/v1/convictions_controller.rb`

**Step 1: Write failing test for Convictions API**

Create: `spec/requests/api/v1/convictions_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe 'Api::V1::Convictions', type: :request do
  describe 'GET /api/v1/convictions' do
    let!(:politician1) { create(:politician, party: 'N-VA') }
    let!(:politician2) { create(:politician, party: 'CD&V') }
    let!(:conviction1) { create(:conviction, politician: politician1, offense_type: 'fraud', conviction_date: '2020-01-01', appeal_status: 'final') }
    let!(:conviction2) { create(:conviction, politician: politician2, offense_type: 'embezzlement', conviction_date: '2015-06-15', appeal_status: 'under_appeal') }

    context 'without filters' do
      it 'returns all convictions with politician info' do
        get '/api/v1/convictions'

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(2)
        expect(json['convictions'][0]).to have_key('politician')
      end
    end

    context 'with date filters' do
      it 'filters by date range' do
        get '/api/v1/convictions', params: { date_from: '2018-01-01', date_to: '2021-12-31' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(1)
        expect(json['convictions'][0]['id']).to eq(conviction1.id)
      end
    end

    context 'with offense_type filter' do
      it 'filters by offense type' do
        get '/api/v1/convictions', params: { offense_type: 'fraud' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(1)
        expect(json['convictions'][0]['offense_type']).to eq('fraud')
      end
    end

    context 'with appeal_status filter' do
      it 'filters by appeal status' do
        get '/api/v1/convictions', params: { appeal_status: 'final' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(1)
      end
    end

    context 'with party filter' do
      it 'filters by politician party' do
        get '/api/v1/convictions', params: { party: 'N-VA' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['convictions'].length).to eq(1)
      end
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run:
```bash
bundle exec rspec spec/requests/api/v1/convictions_spec.rb
```

Expected: FAIL - controller doesn't exist

**Step 3: Create Convictions controller**

Create: `app/controllers/api/v1/convictions_controller.rb`

```ruby
module Api
  module V1
    class ConvictionsController < ApplicationController
      def index
        convictions = Conviction.includes(:politician)

        if params[:date_from].present?
          convictions = convictions.where('conviction_date >= ?', params[:date_from])
        end

        if params[:date_to].present?
          convictions = convictions.where('conviction_date <= ?', params[:date_to])
        end

        if params[:offense_type].present?
          convictions = convictions.where(offense_type: params[:offense_type])
        end

        if params[:appeal_status].present?
          convictions = convictions.where(appeal_status: params[:appeal_status])
        end

        if params[:party].present?
          convictions = convictions.joins(:politician).where(politicians: { party: params[:party] })
        end

        convictions = convictions.page(params[:page]).per(params[:per_page] || 50)

        render json: {
          convictions: convictions.as_json(
            include: {
              politician: {
                only: [:id, :name, :party, :photo_url, :position]
              }
            },
            except: [:created_at, :updated_at]
          ),
          meta: pagination_meta(convictions)
        }
      end

      private

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
```

**Step 4: Run test to verify it passes**

Run:
```bash
bundle exec rspec spec/requests/api/v1/convictions_spec.rb
```

Expected: All tests pass

**Step 5: Commit Convictions API**

Run:
```bash
git add app/controllers/api/v1/convictions_controller.rb spec/requests/api/v1/convictions_spec.rb
git commit -m "feat: add Convictions API with filtering"
```

---

## Task 10: Create API Stats Controller

**Files:**
- Create: `spec/requests/api/v1/stats_spec.rb`
- Create: `app/controllers/api/v1/stats_controller.rb`

**Step 1: Write failing test for Stats API**

Create: `spec/requests/api/v1/stats_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe 'Api::V1::Stats', type: :request do
  describe 'GET /api/v1/stats' do
    let!(:politician1) { create(:politician, party: 'N-VA') }
    let!(:politician2) { create(:politician, party: 'CD&V') }
    let!(:conviction1) { create(:conviction, politician: politician1, offense_type: 'fraud', conviction_date: '2020-01-01') }
    let!(:conviction2) { create(:conviction, politician: politician1, offense_type: 'embezzlement', conviction_date: '2021-01-01') }
    let!(:conviction3) { create(:conviction, politician: politician2, offense_type: 'fraud', conviction_date: '2020-06-01') }

    it 'returns aggregated statistics' do
      get '/api/v1/stats'

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)

      expect(json).to have_key('by_party')
      expect(json).to have_key('by_year')
      expect(json).to have_key('by_offense_type')

      expect(json['by_party']['N-VA']).to eq(2)
      expect(json['by_party']['CD&V']).to eq(1)

      expect(json['by_offense_type']['fraud']).to eq(2)
      expect(json['by_offense_type']['embezzlement']).to eq(1)
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run:
```bash
bundle exec rspec spec/requests/api/v1/stats_spec.rb
```

Expected: FAIL - controller doesn't exist

**Step 3: Create Stats controller**

Create: `app/controllers/api/v1/stats_controller.rb`

```ruby
module Api
  module V1
    class StatsController < ApplicationController
      def index
        convictions = Conviction.includes(:politician)

        by_party = convictions.joins(:politician)
          .group('politicians.party')
          .count

        by_year = convictions
          .group("DATE_PART('year', conviction_date)")
          .count
          .transform_keys(&:to_i)

        by_offense_type = convictions
          .group(:offense_type)
          .count

        render json: {
          by_party: by_party,
          by_year: by_year,
          by_offense_type: by_offense_type,
          total_convictions: convictions.count,
          total_politicians: Politician.joins(:convictions).distinct.count
        }
      end
    end
  end
end
```

**Step 4: Run test to verify it passes**

Run:
```bash
bundle exec rspec spec/requests/api/v1/stats_spec.rb
```

Expected: All tests pass

**Step 5: Commit Stats API**

Run:
```bash
git add app/controllers/api/v1/stats_controller.rb spec/requests/api/v1/stats_spec.rb
git commit -m "feat: add Stats API for aggregated conviction data"
```

---

## Task 11: Setup CORS for API

**Files:**
- Modify: `config/initializers/cors.rb`
- Modify: `Gemfile` (if not already done)

**Step 1: Uncomment rack-cors in Gemfile**

Verify rack-cors is in Gemfile (should be from Task 1)

**Step 2: Configure CORS**

Modify: `config/initializers/cors.rb`

Uncomment and update:
```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # For development. In production, specify your frontend domain

    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

**Step 3: Commit CORS configuration**

Run:
```bash
git add config/initializers/cors.rb
git commit -m "feat: configure CORS for API access"
```

---

## Task 12: Create Wikipedia Scraper Service

**Files:**
- Create: `spec/services/wikipedia_scraper_spec.rb`
- Create: `app/services/wikipedia_scraper.rb`
- Create: `spec/services/politician_parser_spec.rb`
- Create: `app/services/politician_parser.rb`

**Step 1: Setup WebMock and VCR for HTTP testing**

Create: `spec/support/vcr.rb`

```ruby
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.ignore_localhost = true
end
```

Modify: `spec/rails_helper.rb`

Add after other requires:
```ruby
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }
```

**Step 2: Write failing test for WikipediaScraper**

Create: `spec/services/wikipedia_scraper_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe WikipediaScraper do
  describe '#scrape_politician_list' do
    it 'fetches Belgian MP list from Wikipedia' do
      scraper = WikipediaScraper.new
      url = 'https://en.wikipedia.org/wiki/List_of_members_of_the_Federal_Parliament_of_Belgium'

      expect(scraper).to respond_to(:scrape_politician_list)
    end
  end

  describe '#scrape_politician_page' do
    it 'fetches individual politician page' do
      scraper = WikipediaScraper.new

      expect(scraper).to respond_to(:scrape_politician_page)
    end
  end
end
```

**Step 3: Run test to verify it fails**

Run:
```bash
bundle exec rspec spec/services/wikipedia_scraper_spec.rb
```

Expected: FAIL - "uninitialized constant WikipediaScraper"

**Step 4: Create WikipediaScraper service**

Create: `app/services/wikipedia_scraper.rb`

```ruby
class WikipediaScraper
  include HTTParty
  base_uri 'en.wikipedia.org'

  def initialize
    @delay = 2 # seconds between requests
  end

  def scrape_politician_list(url)
    response = self.class.get(url)
    return [] unless response.success?

    doc = Nokogiri::HTML(response.body)
    politicians = []

    # This is a simplified example - actual implementation depends on Wikipedia structure
    doc.css('table.wikitable tr').each do |row|
      cells = row.css('td')
      next if cells.empty?

      name_cell = cells[0]
      link = name_cell.css('a').first

      if link
        politicians << {
          name: link.text.strip,
          wikipedia_url: "https://en.wikipedia.org#{link['href']}"
        }
      end
    end

    politicians
  end

  def scrape_politician_page(url)
    sleep(@delay) # Rate limiting

    response = self.class.get(url)
    return nil unless response.success?

    response.body
  end
end
```

**Step 5: Run test to verify it passes**

Run:
```bash
bundle exec rspec spec/services/wikipedia_scraper_spec.rb
```

Expected: All tests pass

**Step 6: Commit WikipediaScraper**

Run:
```bash
mkdir -p app/services
git add app/services/wikipedia_scraper.rb spec/services/wikipedia_scraper_spec.rb spec/support/vcr.rb
git commit -m "feat: add WikipediaScraper service for fetching politician data"
```

---

## Task 13: Create Conviction Parser Service

**Files:**
- Create: `spec/services/conviction_parser_spec.rb`
- Create: `app/services/conviction_parser.rb`

**Step 1: Write failing test for ConvictionParser**

Create: `spec/services/conviction_parser_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe ConvictionParser do
  describe '#parse' do
    let(:html_with_conviction) do
      <<-HTML
        <html>
          <body>
            <p>John Doe was convicted of fraud in 2020 and sentenced to 2 years in prison.</p>
          </body>
        </html>
      HTML
    end

    let(:html_without_conviction) do
      <<-HTML
        <html>
          <body>
            <p>Jane Smith is a politician from Belgium.</p>
          </body>
        </html>
      HTML
    end

    it 'detects conviction keywords in text' do
      parser = ConvictionParser.new(html_with_conviction)

      expect(parser.has_conviction?).to be true
    end

    it 'returns false when no conviction keywords found' do
      parser = ConvictionParser.new(html_without_conviction)

      expect(parser.has_conviction?).to be false
    end

    it 'extracts conviction data' do
      parser = ConvictionParser.new(html_with_conviction)
      convictions = parser.extract_convictions

      expect(convictions).to be_an(Array)
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run:
```bash
bundle exec rspec spec/services/conviction_parser_spec.rb
```

Expected: FAIL - "uninitialized constant ConvictionParser"

**Step 3: Create ConvictionParser service**

Create: `app/services/conviction_parser.rb`

```ruby
class ConvictionParser
  CONVICTION_KEYWORDS = [
    'convicted', 'condamné', 'condamnée', 'conviction', 'sentenced',
    'fraud', 'fraude', 'embezzlement', 'détournement',
    'corruption', 'guilty', 'coupable'
  ].freeze

  def initialize(html)
    @doc = Nokogiri::HTML(html)
  end

  def has_conviction?
    text = @doc.text.downcase
    CONVICTION_KEYWORDS.any? { |keyword| text.include?(keyword.downcase) }
  end

  def extract_convictions
    return [] unless has_conviction?

    # This is a simplified implementation
    # Real implementation would use more sophisticated parsing
    convictions = []

    # Look for paragraphs containing conviction keywords
    @doc.css('p').each do |paragraph|
      text = paragraph.text.downcase

      if CONVICTION_KEYWORDS.any? { |keyword| text.include?(keyword.downcase) }
        convictions << {
          description: paragraph.text.strip,
          offense_type: extract_offense_type(text),
          conviction_date: extract_date(text)
        }
      end
    end

    convictions.uniq
  end

  private

  def extract_offense_type(text)
    return 'fraud' if text.include?('fraud') || text.include?('fraude')
    return 'embezzlement' if text.include?('embezzlement') || text.include?('détournement')
    return 'corruption' if text.include?('corruption')

    'unknown'
  end

  def extract_date(text)
    # Simple year extraction
    match = text.match(/\b(19\d{2}|20\d{2})\b/)
    match ? Date.new(match[1].to_i, 1, 1) : nil
  rescue
    nil
  end
end
```

**Step 4: Run test to verify it passes**

Run:
```bash
bundle exec rspec spec/services/conviction_parser_spec.rb
```

Expected: All tests pass

**Step 5: Commit ConvictionParser**

Run:
```bash
git add app/services/conviction_parser.rb spec/services/conviction_parser_spec.rb
git commit -m "feat: add ConvictionParser for extracting conviction data from HTML"
```

---

## Task 14: Setup Sidekiq for Background Jobs

**Files:**
- Create: `config/initializers/sidekiq.rb`
- Modify: `config/routes.rb`
- Create: `config/sidekiq.yml`

**Step 1: Create Sidekiq initializer**

Create: `config/initializers/sidekiq.rb`

```ruby
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end
```

**Step 2: Add Sidekiq web UI to routes**

Modify: `config/routes.rb`

Add at the top after `Rails.application.routes.draw do`:
```ruby
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
```

**Step 3: Create Sidekiq configuration file**

Create: `config/sidekiq.yml`

```yaml
:concurrency: 5
:queues:
  - default
  - scraping
  - mailers
```

**Step 4: Commit Sidekiq setup**

Run:
```bash
git add config/initializers/sidekiq.rb config/routes.rb config/sidekiq.yml
git commit -m "feat: setup Sidekiq for background job processing"
```

---

## Task 15: Create Scraper Jobs

**Files:**
- Create: `spec/jobs/scrape_politician_job_spec.rb`
- Create: `app/jobs/scrape_politician_job.rb`
- Create: `spec/jobs/initial_scraper_job_spec.rb`
- Create: `app/jobs/initial_scraper_job.rb`

**Step 1: Write failing test for ScrapePoliticianJob**

Create: `spec/jobs/scrape_politician_job_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe ScrapePoliticianJob, type: :job do
  describe '#perform' do
    let(:politician) { create(:politician, wikipedia_url: 'https://en.wikipedia.org/wiki/Test_Politician') }

    it 'scrapes conviction data for a politician' do
      html = '<html><body><p>Convicted of fraud in 2020.</p></body></html>'

      allow_any_instance_of(WikipediaScraper).to receive(:scrape_politician_page).and_return(html)

      expect {
        ScrapePoliticianJob.perform_now(politician.id)
      }.to change { politician.reload.convictions.count }
    end

    it 'does not create convictions if none found' do
      html = '<html><body><p>A clean politician.</p></body></html>'

      allow_any_instance_of(WikipediaScraper).to receive(:scrape_politician_page).and_return(html)

      expect {
        ScrapePoliticianJob.perform_now(politician.id)
      }.not_to change { Conviction.count }
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run:
```bash
bundle exec rspec spec/jobs/scrape_politician_job_spec.rb
```

Expected: FAIL - "uninitialized constant ScrapePoliticianJob"

**Step 3: Create ScrapePoliticianJob**

Create: `app/jobs/scrape_politician_job.rb`

```ruby
class ScrapePoliticianJob < ApplicationJob
  queue_as :scraping

  def perform(politician_id)
    politician = Politician.find(politician_id)
    return unless politician.wikipedia_url.present?

    scraper = WikipediaScraper.new
    html = scraper.scrape_politician_page(politician.wikipedia_url)
    return unless html

    parser = ConvictionParser.new(html)
    return unless parser.has_conviction?

    convictions_data = parser.extract_convictions

    convictions_data.each do |conviction_data|
      next if conviction_data[:conviction_date].nil?

      politician.convictions.find_or_create_by(
        conviction_date: conviction_data[:conviction_date],
        description: conviction_data[:description]
      ) do |conviction|
        conviction.offense_type = conviction_data[:offense_type]
        conviction.appeal_status = 'final' # default
        conviction.source_url = politician.wikipedia_url
        conviction.verified = false
      end
    end

    Rails.logger.info "Scraped #{convictions_data.length} convictions for #{politician.name}"
  end
end
```

**Step 4: Run test to verify it passes**

Run:
```bash
bundle exec rspec spec/jobs/scrape_politician_job_spec.rb
```

Expected: All tests pass

**Step 5: Write failing test for InitialScraperJob**

Create: `spec/jobs/initial_scraper_job_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe InitialScraperJob, type: :job do
  describe '#perform' do
    it 'enqueues jobs for each politician' do
      politicians_data = [
        { name: 'Test MP', wikipedia_url: 'https://en.wikipedia.org/wiki/Test_MP' },
        { name: 'Another MP', wikipedia_url: 'https://en.wikipedia.org/wiki/Another_MP' }
      ]

      allow_any_instance_of(WikipediaScraper).to receive(:scrape_politician_list).and_return(politicians_data)

      expect {
        InitialScraperJob.perform_now
      }.to change { Politician.count }.by(2)
    end
  end
end
```

**Step 6: Run test to verify it fails**

Run:
```bash
bundle exec rspec spec/jobs/initial_scraper_job_spec.rb
```

Expected: FAIL - "uninitialized constant InitialScraperJob"

**Step 7: Create InitialScraperJob**

Create: `app/jobs/initial_scraper_job.rb`

```ruby
class InitialScraperJob < ApplicationJob
  queue_as :scraping

  BELGIAN_MP_LIST_URL = 'https://en.wikipedia.org/wiki/List_of_members_of_the_Federal_Parliament_of_Belgium'
  BELGIAN_MEP_LIST_URL = 'https://en.wikipedia.org/wiki/List_of_members_of_the_European_Parliament_for_Belgium,_2019–2024'

  def perform
    scraper = WikipediaScraper.new

    # Scrape Federal MPs
    Rails.logger.info "Scraping Belgian Federal MPs..."
    federal_mps = scraper.scrape_politician_list(BELGIAN_MP_LIST_URL)
    create_politicians(federal_mps, 'federal_mp')

    # Scrape MEPs
    Rails.logger.info "Scraping Belgian MEPs..."
    meps = scraper.scrape_politician_list(BELGIAN_MEP_LIST_URL)
    create_politicians(meps, 'mep')

    # Enqueue jobs to scrape each politician's page for convictions
    Politician.find_each do |politician|
      ScrapePoliticianJob.perform_later(politician.id)
    end

    Rails.logger.info "Initial scraping completed. #{Politician.count} politicians added."
  end

  private

  def create_politicians(politicians_data, position)
    politicians_data.each do |data|
      next if data[:name].blank?

      Politician.find_or_create_by(
        name: data[:name],
        wikipedia_url: data[:wikipedia_url]
      ) do |politician|
        politician.party = 'Unknown' # Will be updated manually
        politician.position = position
        politician.active = true
      end
    end
  end
end
```

**Step 8: Run test to verify it passes**

Run:
```bash
bundle exec rspec spec/jobs/initial_scraper_job_spec.rb
```

Expected: All tests pass

**Step 9: Commit scraper jobs**

Run:
```bash
git add app/jobs/ spec/jobs/
git commit -m "feat: add Sidekiq jobs for Wikipedia scraping"
```

---

## Task 16: Setup Superglue.js

**Files:**
- Modify: `Gemfile` (already done in Task 1)
- Run generator
- Create: `app/views/layouts/application.json.props`

**Step 1: Install Superglue**

Run:
```bash
rails generate superglue:install
```

Expected: Superglue installed, creates necessary files

**Step 2: Install JavaScript dependencies**

Run:
```bash
npm install @thoughtbot/superglue
```

Expected: npm packages installed

**Step 3: Commit Superglue setup**

Run:
```bash
git add app/javascript/ package.json package-lock.json
git commit -m "feat: install and configure Superglue.js"
```

---

## Task 17: Create Home Page Controller

**Files:**
- Create: `app/controllers/pages_controller.rb`
- Create: `app/views/pages/home.html.erb`
- Create: `app/views/pages/home.json.props`
- Modify: `config/routes.rb`

**Step 1: Add root route**

Modify: `config/routes.rb`

Add:
```ruby
  root 'pages#home'
  get 'pages/home'
```

**Step 2: Create Pages controller**

Create: `app/controllers/pages_controller.rb`

```ruby
class PagesController < ApplicationController
  def home
    @politicians = Politician.includes(:convictions).limit(100)
    @stats = {
      by_party: Conviction.joins(:politician).group('politicians.party').count,
      total_convictions: Conviction.count,
      total_politicians: Politician.joins(:convictions).distinct.count
    }
  end
end
```

**Step 3: Create home view**

Create: `app/views/pages/home.html.erb`

```erb
<div id="root"></div>
```

**Step 4: Create Superglue props**

Create: `app/views/pages/home.json.props`

```ruby
json.politicians @politicians do |politician|
  json.id politician.id
  json.name politician.name
  json.party politician.party
  json.position politician.position
  json.photo_url politician.photo_url
  json.hemicycle_position politician.hemicycle_position
  json.convictions_count politician.convictions.count

  json.convictions politician.convictions do |conviction|
    json.id conviction.id
    json.conviction_date conviction.conviction_date
    json.offense_type conviction.offense_type
    json.sentence_prison conviction.sentence_prison
    json.sentence_fine conviction.sentence_fine
    json.appeal_status conviction.appeal_status
    json.description conviction.description
  end
end

json.stats @stats
```

**Step 5: Commit home page setup**

Run:
```bash
git add app/controllers/pages_controller.rb app/views/pages/ config/routes.rb
git commit -m "feat: create home page controller with Superglue props"
```

---

## Task 18: Create React Component Structure

**Files:**
- Create: `app/javascript/components/Home.jsx`
- Create: `app/javascript/components/Hemicycle.jsx`
- Create: `app/javascript/components/FilterSidebar.jsx`
- Create: `app/javascript/components/DetailPanel.jsx`
- Modify: `app/javascript/application.js`

**Step 1: Create Home component**

Create: `app/javascript/components/Home.jsx`

```jsx
import React, { useState } from 'react';
import Hemicycle from './Hemicycle';
import FilterSidebar from './FilterSidebar';
import DetailPanel from './DetailPanel';

export default function Home({ politicians, stats }) {
  const [filters, setFilters] = useState({
    search: '',
    parties: [],
    dateRange: [1985, 2030],
    offenseTypes: [],
    appealStatuses: []
  });

  const [selectedPolitician, setSelectedPolitician] = useState(null);

  const filteredPoliticians = politicians.filter(politician => {
    if (filters.search && !politician.name.toLowerCase().includes(filters.search.toLowerCase())) {
      return false;
    }

    if (filters.parties.length > 0 && !filters.parties.includes(politician.party)) {
      return false;
    }

    return true;
  });

  return (
    <div className="flex h-screen">
      <FilterSidebar
        filters={filters}
        setFilters={setFilters}
        stats={stats}
      />

      <div className="flex-1 flex flex-col">
        <div className="flex-1">
          <Hemicycle
            politicians={filteredPoliticians}
            onPoliticianClick={setSelectedPolitician}
          />
        </div>

        {selectedPolitician && (
          <DetailPanel
            politician={selectedPolitician}
            onClose={() => setSelectedPolitician(null)}
          />
        )}
      </div>
    </div>
  );
}
```

**Step 2: Create FilterSidebar component**

Create: `app/javascript/components/FilterSidebar.jsx`

```jsx
import React from 'react';

export default function FilterSidebar({ filters, setFilters, stats }) {
  const parties = Object.keys(stats.by_party);

  return (
    <div className="w-80 bg-gray-100 p-6 overflow-y-auto">
      <h2 className="text-2xl font-bold mb-6">Casier Politique Belgique</h2>

      <div className="mb-6">
        <label className="block text-sm font-medium mb-2">Search</label>
        <input
          type="text"
          className="w-full px-3 py-2 border rounded"
          placeholder="Politician name..."
          value={filters.search}
          onChange={(e) => setFilters({ ...filters, search: e.target.value })}
        />
      </div>

      <div className="mb-6">
        <label className="block text-sm font-medium mb-2">Date Range</label>
        <div className="flex gap-2">
          <input
            type="number"
            className="w-20 px-2 py-1 border rounded"
            value={filters.dateRange[0]}
            onChange={(e) => setFilters({
              ...filters,
              dateRange: [parseInt(e.target.value), filters.dateRange[1]]
            })}
          />
          <span>-</span>
          <input
            type="number"
            className="w-20 px-2 py-1 border rounded"
            value={filters.dateRange[1]}
            onChange={(e) => setFilters({
              ...filters,
              dateRange: [filters.dateRange[0], parseInt(e.target.value)]
            })}
          />
        </div>
      </div>

      <div className="mb-6">
        <label className="block text-sm font-medium mb-2">Parties</label>
        {parties.map(party => (
          <label key={party} className="flex items-center mb-2">
            <input
              type="checkbox"
              className="mr-2"
              checked={filters.parties.includes(party)}
              onChange={(e) => {
                if (e.target.checked) {
                  setFilters({ ...filters, parties: [...filters.parties, party] });
                } else {
                  setFilters({
                    ...filters,
                    parties: filters.parties.filter(p => p !== party)
                  });
                }
              }}
            />
            {party} ({stats.by_party[party]})
          </label>
        ))}
      </div>

      <div className="mb-6">
        <p className="text-sm text-gray-600">
          Total: {stats.total_convictions} convictions, {stats.total_politicians} politicians
        </p>
      </div>
    </div>
  );
}
```

**Step 3: Create DetailPanel component**

Create: `app/javascript/components/DetailPanel.jsx`

```jsx
import React from 'react';

export default function DetailPanel({ politician, onClose }) {
  return (
    <div className="border-t bg-white p-6 h-64 overflow-y-auto">
      <div className="flex justify-between items-start mb-4">
        <div>
          <h3 className="text-xl font-bold">{politician.name}</h3>
          <p className="text-gray-600">{politician.party} - {politician.position}</p>
        </div>
        <button
          onClick={onClose}
          className="text-gray-500 hover:text-gray-700"
        >
          ✕
        </button>
      </div>

      <div className="space-y-4">
        <h4 className="font-semibold">Convictions ({politician.convictions.length})</h4>
        {politician.convictions.map(conviction => (
          <div key={conviction.id} className="border-l-4 border-red-500 pl-4">
            <p className="font-medium">{conviction.offense_type}</p>
            <p className="text-sm text-gray-600">{conviction.conviction_date}</p>
            {conviction.sentence_prison && (
              <p className="text-sm">Prison: {conviction.sentence_prison}</p>
            )}
            {conviction.sentence_fine && (
              <p className="text-sm">Fine: €{conviction.sentence_fine}</p>
            )}
            <p className="text-sm mt-2">{conviction.description}</p>
            <p className="text-xs text-gray-500">Status: {conviction.appeal_status}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
```

**Step 4: Create basic Hemicycle component (will enhance with D3 later)**

Create: `app/javascript/components/Hemicycle.jsx`

```jsx
import React from 'react';

export default function Hemicycle({ politicians, onPoliticianClick }) {
  return (
    <div className="w-full h-full flex items-center justify-center bg-gray-50">
      <div className="text-center">
        <h3 className="text-xl mb-4">Hemicycle Visualization</h3>
        <p className="text-gray-600 mb-4">
          Showing {politicians.length} politicians with convictions
        </p>
        <div className="flex flex-wrap gap-2 justify-center max-w-4xl">
          {politicians.slice(0, 50).map(politician => (
            <button
              key={politician.id}
              onClick={() => onPoliticianClick(politician)}
              className="px-3 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 text-sm"
              title={`${politician.name} - ${politician.convictions_count} convictions`}
            >
              {politician.name.split(' ')[0]}
            </button>
          ))}
        </div>
        <p className="text-sm text-gray-500 mt-4">
          (D3.js visualization will be implemented in next task)
        </p>
      </div>
    </div>
  );
}
```

**Step 5: Commit React components**

Run:
```bash
git add app/javascript/components/
git commit -m "feat: create React component structure for frontend"
```

---

## Task 19: Integrate D3.js Hemicycle Visualization

**Files:**
- Modify: `app/javascript/components/Hemicycle.jsx`
- Install D3.js

**Step 1: Install D3.js**

Run:
```bash
npm install d3
```

**Step 2: Replace Hemicycle with D3 visualization**

Modify: `app/javascript/components/Hemicycle.jsx`

```jsx
import React, { useEffect, useRef } from 'react';
import * as d3 from 'd3';

const PARTY_COLORS = {
  'N-VA': '#FFED00',
  'CD&V': '#FF6200',
  'Open VLD': '#003D6D',
  'sp.a': '#FF0000',
  'Groen': '#00B050',
  'Vlaams Belang': '#FFE500',
  'PVDA': '#AA0000',
  'MR': '#0047AB',
  'PS': '#FF0000',
  'Ecolo': '#00B050',
  'cdH': '#FF6200',
  'DéFI': '#EC008C'
};

export default function Hemicycle({ politicians, onPoliticianClick }) {
  const svgRef = useRef();

  useEffect(() => {
    if (!politicians || politicians.length === 0) return;

    // Clear previous visualization
    d3.select(svgRef.current).selectAll('*').remove();

    const width = 1000;
    const height = 600;
    const centerX = width / 2;
    const centerY = height - 100;
    const radius = 400;

    const svg = d3.select(svgRef.current)
      .attr('width', width)
      .attr('height', height);

    // Create groups for convictions (each dot is a conviction)
    const allConvictions = [];
    politicians.forEach(politician => {
      politician.convictions.forEach(conviction => {
        allConvictions.push({
          ...conviction,
          politician: politician
        });
      });
    });

    // Sort by party and position
    const sortedConvictions = allConvictions.sort((a, b) => {
      return a.politician.party.localeCompare(b.politician.party);
    });

    // Calculate hemicycle positions
    const angleStep = Math.PI / (sortedConvictions.length + 1);

    const convictionsWithPositions = sortedConvictions.map((conviction, i) => {
      const angle = Math.PI - (angleStep * (i + 1));
      const x = centerX + radius * Math.cos(angle);
      const y = centerY + radius * Math.sin(angle);

      return {
        ...conviction,
        x,
        y
      };
    });

    // Create tooltip
    const tooltip = d3.select('body')
      .append('div')
      .attr('class', 'tooltip')
      .style('position', 'absolute')
      .style('padding', '10px')
      .style('background', 'white')
      .style('border', '1px solid #ddd')
      .style('border-radius', '4px')
      .style('pointer-events', 'none')
      .style('opacity', 0);

    // Draw conviction dots
    svg.selectAll('circle')
      .data(convictionsWithPositions)
      .enter()
      .append('circle')
      .attr('cx', d => d.x)
      .attr('cy', d => d.y)
      .attr('r', 8)
      .attr('fill', d => PARTY_COLORS[d.politician.party] || '#999')
      .attr('stroke', '#333')
      .attr('stroke-width', 1)
      .attr('opacity', 0.8)
      .style('cursor', 'pointer')
      .on('mouseover', function(event, d) {
        d3.select(this)
          .attr('r', 12)
          .attr('opacity', 1);

        tooltip
          .style('opacity', 1)
          .html(`
            <strong>${d.politician.name}</strong><br/>
            Party: ${d.politician.party}<br/>
            Offense: ${d.offense_type}<br/>
            Date: ${d.conviction_date}<br/>
            ${d.sentence_prison ? `Prison: ${d.sentence_prison}<br/>` : ''}
            ${d.sentence_fine ? `Fine: €${d.sentence_fine}` : ''}
          `)
          .style('left', (event.pageX + 10) + 'px')
          .style('top', (event.pageY - 10) + 'px');
      })
      .on('mouseout', function() {
        d3.select(this)
          .attr('r', 8)
          .attr('opacity', 0.8);

        tooltip.style('opacity', 0);
      })
      .on('click', function(event, d) {
        onPoliticianClick(d.politician);
      });

    // Cleanup on unmount
    return () => {
      tooltip.remove();
    };
  }, [politicians, onPoliticianClick]);

  return (
    <div className="w-full h-full flex items-center justify-center">
      <svg ref={svgRef}></svg>
    </div>
  );
}
```

**Step 3: Test visualization loads**

Run:
```bash
npm run build
```

Expected: Build successful

**Step 4: Commit D3 visualization**

Run:
```bash
git add app/javascript/components/Hemicycle.jsx package.json package-lock.json
git commit -m "feat: implement D3.js hemicycle visualization"
```

---

## Task 20: Add Seed Data for Testing

**Files:**
- Create: `db/seeds.rb`

**Step 1: Create seed data**

Modify: `db/seeds.rb`

```ruby
# Create admin user for ActiveAdmin
AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
  admin.password = 'password'
  admin.password_confirmation = 'password'
end

puts "Created admin user: admin@example.com / password"

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
```

**Step 2: Run seeds**

Run:
```bash
rails db:seed
```

Expected: Sample data created

**Step 3: Commit seed data**

Run:
```bash
git add db/seeds.rb
git commit -m "feat: add seed data for testing"
```

---

## Task 21: Create Procfile for Development

**Files:**
- Create: `Procfile.dev`

**Step 1: Create development Procfile**

Create: `Procfile.dev`

```
web: bin/rails server -p 3000
worker: bundle exec sidekiq
js: npm run build -- --watch
```

**Step 2: Commit Procfile**

Run:
```bash
git add Procfile.dev
git commit -m "feat: add Procfile for local development"
```

---

## Task 22: Create Production Procfile

**Files:**
- Create: `Procfile`

**Step 1: Create production Procfile**

Create: `Procfile`

```
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
release: bundle exec rails db:migrate
```

**Step 2: Commit production Procfile**

Run:
```bash
git add Procfile
git commit -m "feat: add production Procfile for Heroku/Render"
```

---

## Task 23: Create README

**Files:**
- Create: `README.md`

**Step 1: Write comprehensive README**

Create: `README.md`

```markdown
# Casier Politique Belgique

Database of Belgian politician convictions (1985-2030), featuring interactive hemicycle visualization.

## Features

- Track convictions of Belgian Federal MPs and MEPs
- Interactive D3.js hemicycle visualization
- Search and filter by party, date, offense type
- Admin interface for data curation
- Wikipedia scraping pipeline

## Tech Stack

- Rails 7.1+ API backend
- PostgreSQL database
- Sidekiq for background jobs
- ActiveAdmin for data management
- React frontend via Superglue.js
- D3.js visualization

## Setup

### Prerequisites

- Ruby 3.2+
- Node.js 18+
- PostgreSQL 14+
- Redis

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   npm install
   ```

3. Setup database:
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. Start development server:
   ```bash
   foreman start -f Procfile.dev
   ```

5. Visit http://localhost:3000

### Admin Access

- URL: http://localhost:3000/admin
- Email: admin@example.com
- Password: password

## Usage

### Running the Wikipedia Scraper

From Rails console:
```ruby
InitialScraperJob.perform_now
```

This will:
1. Scrape Belgian MP and MEP lists from Wikipedia
2. Create politician records
3. Scrape each politician's page for convictions
4. Extract and store conviction data

### API Endpoints

- `GET /api/v1/politicians` - List all politicians
- `GET /api/v1/politicians/:id` - Get politician details
- `GET /api/v1/convictions` - List convictions with filters
- `GET /api/v1/stats` - Get aggregated statistics

## Deployment

### Heroku

```bash
heroku create casier-pol-be
heroku addons:create heroku-postgresql:standard-0
heroku addons:create heroku-redis:premium-0
git push heroku main
heroku run rails db:migrate db:seed
```

### Render

1. Create new Web Service
2. Add PostgreSQL database
3. Add Redis instance
4. Deploy from GitHub

## Development

Run tests:
```bash
bundle exec rspec
```

Run linter:
```bash
rubocop
```

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License

MIT
```

**Step 2: Commit README**

Run:
```bash
git add README.md
git commit -m "docs: add comprehensive README"
```

---

## Task 24: Final Verification

**Step 1: Run all tests**

Run:
```bash
bundle exec rspec
```

Expected: All tests passing

**Step 2: Verify Rails server starts**

Run:
```bash
rails server
```

Expected: Server starts on port 3000

Stop server: Ctrl+C

**Step 3: Verify Sidekiq works**

Run:
```bash
bundle exec sidekiq
```

Expected: Sidekiq starts successfully

Stop Sidekiq: Ctrl+C

**Step 4: Final commit**

Run:
```bash
git add .
git commit -m "chore: final verification and cleanup"
```

---

## Implementation Complete!

The Casier Politique Belgium application is now ready. Key features implemented:

✅ Rails API with Politicians and Convictions models
✅ PostgreSQL database with proper indexes
✅ ActiveAdmin for data curation
✅ Wikipedia scraping pipeline with Sidekiq
✅ React frontend with Superglue.js integration
✅ D3.js hemicycle visualization
✅ Search and filter functionality
✅ API endpoints for frontend
✅ Seed data for testing
✅ Production-ready configuration

Next steps:
1. Deploy to Heroku/Render
2. Run initial Wikipedia scrape
3. Curate and verify conviction data
4. Launch to public
