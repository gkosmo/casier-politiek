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
