@echo off
REM Database setup script for Vilara website
REM Initializes PostgreSQL schema on Google Cloud SQL

echo ====================================
echo Vilara Database Setup Script
echo ====================================
echo.

REM Set environment variables
set PROJECT_ID=vilara-dev
set INSTANCE_NAME=vilara-dev-sql
set DATABASE_NAME=appdb
set DB_USER=appuser
set REGION=us-central1

REM Authenticate
echo Step 1: Setting up GCP configuration...
gcloud config set account tim@vilara.ai
gcloud config set project %PROJECT_ID%

REM Verify authentication
gcloud auth list --filter="tim@vilara.ai" --format="value(account)" | findstr "tim@vilara.ai" >NUL
if %errorlevel% neq 0 (
    echo.
    echo You need to authenticate first. Running login...
    gcloud auth login tim@vilara.ai
    pause
)

REM Verify project
gcloud projects describe %PROJECT_ID% >NUL 2>&1
if %errorlevel% neq 0 (
    echo.
    echo Error: Cannot access project %PROJECT_ID%
    echo Available projects:
    gcloud projects list --format="table(projectId,name)"
    pause
    exit /b 1
)

REM Check if database exists
echo.
echo Step 2: Checking database status...
gcloud sql databases list --instance=%INSTANCE_NAME% | findstr %DATABASE_NAME% >NUL
if %errorlevel%==0 (
    echo Database '%DATABASE_NAME%' exists
) else (
    echo Creating database '%DATABASE_NAME%'...
    gcloud sql databases create %DATABASE_NAME% --instance=%INSTANCE_NAME%
)

REM Check if user exists
echo.
echo Step 3: Checking database user...
gcloud sql users list --instance=%INSTANCE_NAME% | findstr %DB_USER% >NUL
if %errorlevel%==0 (
    echo User '%DB_USER%' exists
) else (
    echo Creating user '%DB_USER%'...
    echo Please enter a password for the database user:
    set /p DB_PASSWORD=Password: 
    gcloud sql users create %DB_USER% --instance=%INSTANCE_NAME% --password=%DB_PASSWORD%
    
    echo.
    echo Storing password in Secret Manager...
    echo %DB_PASSWORD% | gcloud secrets create db-appuser-password --data-file=- 2>NUL
    if %errorlevel% neq 0 (
        echo Secret already exists, updating...
        echo %DB_PASSWORD% | gcloud secrets versions add db-appuser-password --data-file=-
    )
)

REM Create SendGrid API key secret if needed
echo.
echo Step 4: Setting up SendGrid API key...
gcloud secrets describe sendgrid-api-key >NUL 2>&1
if %errorlevel% neq 0 (
    echo SendGrid API key secret not found.
    echo Please enter your SendGrid API key:
    set /p SENDGRID_KEY=SendGrid API Key: 
    echo %SENDGRID_KEY% | gcloud secrets create sendgrid-api-key --data-file=-
) else (
    echo SendGrid API key secret exists
)

REM Import schema
echo.
echo Step 5: Importing database schema...
echo To import the schema, you need to connect to Cloud SQL.
echo.
echo Option 1: Use Cloud SQL Proxy (recommended for local development)
echo   1. Download Cloud SQL Proxy from: https://cloud.google.com/sql/docs/mysql/sql-proxy
echo   2. Run: cloud_sql_proxy -instances=%PROJECT_ID%:%REGION%:%INSTANCE_NAME%=tcp:5432
echo   3. In another terminal: psql -h localhost -U %DB_USER% -d %DATABASE_NAME% -f api/schema.sql
echo.
echo Option 2: Use Cloud Shell
echo   1. Open Cloud Shell: https://console.cloud.google.com/cloudshell
echo   2. Upload api/schema.sql to Cloud Shell
echo   3. Run: gcloud sql connect %INSTANCE_NAME% --user=%DB_USER% --database=%DATABASE_NAME%
echo   4. Paste the contents of schema.sql
echo.
echo Option 3: Use the Cloud Console SQL editor
echo   1. Go to: https://console.cloud.google.com/sql/instances/%INSTANCE_NAME%/databases
echo   2. Click on %DATABASE_NAME%
echo   3. Use the Query editor to run the schema.sql contents
echo.

REM Configure automated backups
echo Step 6: Configuring automated backups...
gcloud sql instances patch %INSTANCE_NAME% ^
    --backup-start-time=02:00 ^
    --backup-location=%REGION% ^
    --retained-backups-count=7 ^
    --retained-transaction-log-days=7

echo.
echo ====================================
echo Database Setup Complete!
echo ====================================
echo.
echo Next steps:
echo 1. Import the schema using one of the options above
echo 2. Run deploy.bat to deploy the application
echo.
pause