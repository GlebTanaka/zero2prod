# Check if sqlx is installed
if (!(Get-Command sqlx -ErrorAction SilentlyContinue)) {
    Write-Error "Error: sqlx is not installed."
    Write-Error "Use:"
    Write-Error "    cargo install --version='~0.8' sqlx-cli --no-default-features --features rustls,postgres"
    exit 1
}

# Set default values
$DB_PORT = if ($env:DB_PORT) { $env:DB_PORT } else { "5432" }
$SUPERUSER = if ($env:SUPERUSER) { $env:SUPERUSER } else { "postgres" }
$SUPERUSER_PWD = if ($env:SUPERUSER_PWD) { $env:SUPERUSER_PWD } else { "password" }
$APP_USER = if ($env:APP_USER) { $env:APP_USER } else { "app" }
$APP_USER_PWD = if ($env:APP_USER_PWD) { $env:APP_USER_PWD } else { "secret" }
$APP_DB_NAME = if ($env:APP_DB_NAME) { $env:APP_DB_NAME } else { "newsletter" }

# Check for running postgres container
if (!$env:SKIP_DOCKER) {
    $RUNNING_POSTGRES_CONTAINER = docker ps --filter 'name=postgres' --format '{{.ID}}'
    if ($RUNNING_POSTGRES_CONTAINER) {
        Write-Error "There is a postgres container already running, kill it with:"
        Write-Error "    docker kill ${RUNNING_POSTGRES_CONTAINER}"
        exit 1
    }

    $CONTAINER_NAME = "postgres_newsletter"

    # Launch postgres using Docker
    docker run `
        --env POSTGRES_USER=${SUPERUSER} `
        --env POSTGRES_PASSWORD=${SUPERUSER_PWD} `
        --health-cmd="pg_isready -U ${SUPERUSER} || exit 1" `
        --health-interval=1s `
        --health-timeout=5s `
        --health-retries=5 `
        --publish "${DB_PORT}:5432" `
        --detach `
        --name "${CONTAINER_NAME}" `
        postgres:16-alpine -N 1000

    # Wait for postgres to be healthy
    do {
        $health = docker inspect -f "{{.State.Health.Status}}" ${CONTAINER_NAME}
        if ($health -ne "healthy") {
            Write-Host "Postgres is still unavailable - sleeping"
            Start-Sleep -Seconds 1
        }
    } while ($health -ne "healthy")

    # Create application user
    $CREATE_QUERY = "CREATE USER ${APP_USER} WITH PASSWORD '${APP_USER_PWD}';"
    docker exec -it "${CONTAINER_NAME}" psql -U "${SUPERUSER}" -c "${CREATE_QUERY}"

    # Grant create db privileges
    $GRANT_QUERY = "ALTER USER ${APP_USER} CREATEDB;"
    docker exec -it "${CONTAINER_NAME}" psql -U "${SUPERUSER}" -c "${GRANT_QUERY}"
}

Write-Host "Postgres is up and running on port ${DB_PORT} - running migrations now!"

# Set up database URL and create database
$env:DATABASE_URL = "postgres://${APP_USER}:${APP_USER_PWD}@localhost:${DB_PORT}/${APP_DB_NAME}"
sqlx database create
sqlx migrate run

Write-Host "Postgres has been migrated, ready to go!"