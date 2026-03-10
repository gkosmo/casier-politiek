# Casier Politique Belgium - Design Document

**Date:** 2026-03-10
**Purpose:** Database of Belgian politician convictions (1985-2030)
**Model:** Based on https://casier-politique.fr/

---

## Overview

A web application tracking convictions of Belgian federal and EU parliament politicians, featuring interactive hemicycle visualization, search/filter capabilities, and admin curation tools.

**Scope:**
- Federal Belgian Parliament members
- Belgian Members of European Parliament (MEPs)
- Convictions from 1985-2030
- Data sourced from Wikipedia + manual curation

---

## Architecture

### High-Level System Design

**Three-Layer Architecture:**

1. **Rails API Backend** (`casier-pol-be`)
   - PostgreSQL database
   - RESTful API endpoints
   - Background scraping jobs (Sidekiq)
   - ActiveAdmin for data curation
   - Optional authentication (Devise)

2. **React Frontend** (via Superglue.js)
   - Interactive hemicycle visualization (D3.js)
   - Search and filter interface
   - Detail views with conviction information
   - Superglue handles Rails-React state sync

3. **Data Pipeline**
   - Wikipedia scraper (Nokogiri + HTTParty)
   - Extracts conviction data from politician pages
   - Stores unverified data for admin review

**Technology Stack:**
- Rails 7.1+
- PostgreSQL
- Sidekiq + Redis
- ActiveAdmin
- Superglue.js
- React + D3.js

---

## Data Model

### Politicians Table

```ruby
create_table :politicians do |t|
  t.string :name, null: false
  t.string :party, null: false
  t.string :photo_url
  t.string :position, null: false # "Federal MP" or "MEP"
  t.string :wikipedia_url
  t.boolean :active, default: true
  t.json :hemicycle_position # {x: float, y: float}
  t.timestamps
end

add_index :politicians, :name
add_index :politicians, :party
add_index :politicians, :position
```

### Convictions Table

```ruby
create_table :convictions do |t|
  t.references :politician, null: false, foreign_key: true
  t.date :conviction_date, null: false
  t.string :offense_type, null: false # fraud, embezzlement, defamation, etc.
  t.string :sentence_prison
  t.decimal :sentence_fine, precision: 10, scale: 2
  t.string :sentence_ineligibility
  t.string :appeal_status, null: false # final, under_appeal, cassation
  t.text :description
  t.string :source_url, null: false
  t.boolean :verified, default: false
  t.timestamps
end

add_index :convictions, :politician_id
add_index :convictions, :conviction_date
add_index :convictions, :offense_type
add_index :convictions, :appeal_status
```

### Relationships

- `Politician has_many :convictions`
- `Conviction belongs_to :politician`

---

## API Endpoints

### Public API

**GET /api/v1/politicians**
- Query params: `party`, `position`, `search`
- Returns: List of politicians with conviction counts
- Pagination: Yes

**GET /api/v1/politicians/:id**
- Returns: Politician details + all convictions

**GET /api/v1/convictions**
- Query params: `date_from`, `date_to`, `offense_type`, `appeal_status`, `party`
- Returns: Filtered convictions with politician info
- Pagination: Yes
- Powers main search/filter interface

**GET /api/v1/stats**
- Returns: Aggregated statistics
  - Convictions by party
  - Convictions by year
  - Convictions by offense type
- Used for hemicycle visualization

### Admin Interface

- Handled by ActiveAdmin
- `/admin/politicians` - CRUD for politicians
- `/admin/convictions` - CRUD for convictions
- Standard authentication required

### Response Format

- JSON format with metadata
- Includes pagination info
- Superglue handles state mapping to React

### Performance

- Eager loading to prevent N+1 queries
- API response caching (Russian Doll)
- Proper database indexes

---

## Wikipedia Scraping Pipeline

### Scraper Architecture

**Initial Scraping (One-time):**
1. Scrape Belgian Federal Parliament member list from Wikipedia
2. Scrape Belgian MEP list from Wikipedia
3. For each politician:
   - Visit individual Wikipedia page
   - Parse for conviction-related keywords (condamné, convicted, fraude, etc.)
   - Extract structured data from infoboxes and page text
   - Store with `verified: false`

### Implementation

**Service Classes:**
- `WikipediaScraper` - main scraper orchestrator
- `PoliticianParser` - extracts politician data
- `ConvictionParser` - extracts conviction details from text

**Libraries:**
- Nokogiri (HTML parsing)
- HTTParty (HTTP requests)
- Rate limiting: 1-2 second delay between requests

**Background Jobs (Sidekiq):**
- `InitialScraperJob` - full scrape of all politicians
- `UpdatePoliticianJob` - refresh individual politician
- Optional: scheduled periodic updates

### Data Quality

- All scraped data marked `verified: false`
- Admin reviews in ActiveAdmin interface
- Manual corrections override scraped data
- Track `last_scraped_at` timestamp on records

### Edge Cases

- Handle missing data gracefully (nil checks)
- Support multiple convictions per politician
- Handle party changes over time
- Support bilingual content (Dutch/French)

---

## Frontend & Visualization

### Superglue.js Integration

- Rails serves React components via Superglue
- Automatic state synchronization
- No separate API fetch calls needed
- Server-side rendering support

### Main Page Components

**1. Hemicycle Visualization (D3.js)**
- SVG-based semicircle layout
- Each dot = one conviction
- Positioned by party (left-right spectrum)
- Color-coded by party
- Size indicates severity (prison/fine)
- Interactive tooltips on hover:
  - Politician name + photo
  - Conviction details
  - Date, offense type, sentence
  - Link to source

**2. Search & Filter Sidebar**
- Text search (politician name, party)
- Date range slider (1985-2030)
- Party checkboxes (dynamic from data)
- Offense type filter
- Appeal status filter
- Clear filters button

**3. Detail Panel**
- Opens on dot click
- Full conviction history
- Source links to Wikipedia
- Photo and biographical info

### Visualization Library

**Recommendation: D3.js**
- Most powerful for custom layouts
- Full control over hemicycle positioning
- Rich interaction support
- Steeper learning curve but worth it

---

## Deployment & Infrastructure

### Hosting Platform

**Heroku or Render (recommended)**

**Services Required:**
- Web dyno/instance (Rails + Superglue + React)
- Worker dyno/instance (Sidekiq)
- PostgreSQL database (Standard tier)
- Redis (for Sidekiq queue)

### Configuration

**Environment Variables:**
- `DATABASE_URL`
- `REDIS_URL`
- `RAILS_MASTER_KEY`
- `ADMIN_EMAIL` / `ADMIN_PASSWORD`
- Optional: Wikipedia API credentials

### Deployment Flow

1. Push code to GitHub
2. Auto-deploy to Heroku/Render
3. Run migrations automatically
4. Precompile assets (Rails + React)
5. Restart worker processes

### Initial Data Population

1. Deploy application
2. Trigger initial scrape via admin panel or Rails console
3. Let scraping job run in background
4. Admin reviews and verifies data
5. Enable public access once data is curated

### Monitoring

- Platform logs (Heroku/Render)
- Sidekiq web UI for job monitoring
- Database performance metrics
- Optional: Sentry for error tracking

### Backup Strategy

- Daily automated PostgreSQL backups (platform-provided)
- Periodic JSON export of verified data
- Git repository for code versioning

---

## Implementation Phases

### Phase 1: Rails Backend Setup
- Initialize Rails app
- Set up PostgreSQL database
- Create models and migrations
- Set up ActiveAdmin
- Basic API endpoints

### Phase 2: Wikipedia Scraper
- Build scraper service classes
- Set up Sidekiq
- Create scraping jobs
- Test with small dataset
- Implement rate limiting

### Phase 3: API Development
- Build RESTful endpoints
- Add filtering and search
- Implement pagination
- Add caching
- API testing

### Phase 4: Superglue + React Frontend
- Set up Superglue.js
- Create React component structure
- Build hemicycle visualization (D3.js)
- Implement search/filter UI
- Detail panel views

### Phase 5: Data Curation & Launch
- Run initial scrape
- Admin verification workflow
- Data quality checks
- Deploy to production
- Public launch

---

## Success Criteria

- Database contains 100+ Belgian politicians
- All federal MPs and MEPs with convictions included
- Interactive hemicycle visualization functional
- Search and filters work smoothly
- Admin can easily add/edit/verify data
- Fast page load times (<2 seconds)
- Mobile responsive
- Accessible and accurate source citations
