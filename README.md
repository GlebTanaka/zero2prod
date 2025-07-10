# Zero to Production in Rust

This project is a step-by-step reconstruction of the application described in the book "Zero to Production in Rust" by Luca Palmieri. It demonstrates how to build a production-ready web application using Rust.

## Project Overview

The application is a newsletter subscription service that allows users to subscribe with their email and name. It's built using modern Rust web development practices and follows a clean architecture approach.

## Steps Taken So Far

1. **Project Setup**
   - Created a new Rust project with both a library and a binary component
   - Set up the project structure with separate modules for different concerns

2. **Web Server Implementation**
   - Integrated Actix Web as the web framework
   - Implemented a health check endpoint for monitoring
   - Set up a subscription endpoint for newsletter sign-ups

3. **Database Integration**
   - Added PostgreSQL support using SQLx
   - Created a database migration for the subscriptions table
   - Implemented database connection pooling

4. **Configuration Management**
   - Added structured configuration using the config crate
   - Created a YAML configuration file for application settings
   - Implemented environment-based configuration

5. **Development Tooling**
   - Added database initialization scripts for development
   - Set up Docker integration for PostgreSQL

## Project Structure

- `src/`: Source code
  - `main.rs`: Application entry point
  - `lib.rs`: Library exports
  - `configuration.rs`: Configuration management
  - `startup.rs`: Server setup and initialization
  - `routes/`: API endpoints
    - `health_check.rs`: Health check endpoint
    - `subscriptions.rs`: Subscription handling

- `migrations/`: Database migrations
  - `20250502133713_create_subscriptions_table.sql`: Creates the subscriptions table

- `scripts/`: Utility scripts
  - `init_db.ps1`: PowerShell script for setting up the database (Windows)
  - `init_db.sh`: Bash script for setting up the database (Unix/Linux)

- `configuration.yaml`: Application configuration

## Technologies Used

- **Rust**: Programming language
- **Actix Web**: Web framework
- **SQLx**: Database toolkit and ORM
- **PostgreSQL**: Database
- **Tokio**: Async runtime
- **config**: Configuration management
- **serde**: Serialization/deserialization
- **uuid**: UUID generation
- **chrono**: Date and time handling
- **Docker**: Containerization for development

## Setup Instructions

### Prerequisites

- Rust toolchain (install via [rustup](https://rustup.rs/))
- Docker (for running PostgreSQL)
- SQLx CLI (install with `cargo install --version='~0.8' sqlx-cli --no-default-features --features rustls,postgres`)

### Database Setup

1. Run the database initialization script:

   **Windows**:
   ```powershell
   .\scripts\init_db.ps1
   ```

   **Unix/Linux**:
   ```bash
   ./scripts/init_db.sh
   ```

   This will:
   - Start a PostgreSQL container
   - Create the application database user
   - Create the database
   - Run migrations

### Running the Application

1. Build and run the application:
   ```
   cargo run
   ```

2. The application will be available at http://127.0.0.1:8000

## API Endpoints

- `GET /health_check`: Health check endpoint that returns a 200 OK response
- `POST /subscriptions`: Subscribe to the newsletter with email and name

## Next Steps

Future enhancements could include:
- Email validation
- Authentication and authorization
- Newsletter sending functionality
- Admin interface
- Deployment configuration