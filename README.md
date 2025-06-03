# Recipe Finder

A Ruby on Rails application that helps users find recipes based on available ingredients. The application allows users to search through a database of recipes and find matches based on the ingredients they have at hand.

## User Stories

### Core Features
- As a user, I want to search for recipes using ingredients I have, so I can make meals with available items
- As a user, I want to see recipes sorted by how many of my ingredients they use, so I can maximize my available ingredients
- As a user, I want to sort recipes by total cooking time, so I can find quick recipes when I'm short on time
- As a user, I want to see detailed recipe information including prep time and cook time, so I can plan my cooking schedule

### Search and Sort
- Users can enter multiple ingredients separated by commas
- Search results can be sorted by:
  - Most matching ingredients (default)
  - Quickest to make (ascending total time)
  - Longest to make (descending total time)
- Search results show:
  - Recipe title
  - Rating
  - Total cooking time (prep + cook time)
  - Preparation time
  - Cooking time

### Recipe Details
Each recipe includes:
- Title
- Preparation time
- Cooking time
- List of ingredients with measurements
- Rating (out of 5 stars)
- Cuisine type
- Category
- Author information

## Features

- Search recipes by available ingredients
- View detailed recipe information including:
  - Title
  - Preparation time
  - Cooking time
  - Ingredients list
  - Ratings
  - Cuisine type
  - Category
  - Author information
- Browse recipes by rating
- Responsive web interface

## Prerequisites

- Docker and Docker Compose
- Git

## Quick Start

1. Clone the repository:
```bash
git clone <repository-url>
cd find_recipes
```

2. Create a `.env` file in the project root and add your Rails master key:
```bash
RAILS_MASTER_KEY=your_master_key_here
```

3. Build and start the application:
```bash
docker compose up --build
```

The application will be available at `http://localhost:3000`

## Development

The application uses Docker for development and production environments. The setup includes:

- Ruby 3.4.4
- PostgreSQL 15
- Development-specific configurations with live code reloading

### Development Setup

1. Start the development environment:
```bash
docker compose up
```

2. Run database migrations:
```bash
docker compose exec app rails db:migrate
```

3. Load sample data (if available):
```bash
docker compose exec app rails db:seed
```

### Running Tests

```bash
docker compose exec app rails test
```

## Production Deployment

1. Build the production image:
```bash
docker build --build-arg RAILS_ENV=production .
```

2. Required environment variables for production:
- `RAILS_MASTER_KEY`
- `DATABASE_URL`
- `RAILS_ENV=production`

## Database Configuration

The application uses PostgreSQL with the following default configuration:

- Development Database: `find_recipes_development`
- Test Database: `find_recipes_test`
- Production Database: `find_recipes_production`
- Default Port: 5433 (to avoid conflicts with existing PostgreSQL installations)

## API Documentation

### Search Endpoint

```
GET /recipes/search
```

Parameters:
- `ingredients`: Comma-separated list of ingredients
- `sort_by`: Sorting preference (options: 'relevance', 'time_asc', 'time_desc')

Response Format:
```json
{
  "total_recipes": 42,
  "ingredients_searched": ["milk", "sugar", "eggs"],
  "sort_by": "relevance",
  "recipes": [
    {
      "id": 1,
      "title": "Recipe Name",
      "prep_time": 10,
      "cook_time": 20,
      "total_time": 30,
      "ratings": 4.5,
      "matching_ingredients_count": 3
    }
  ]
}
```