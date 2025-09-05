@echo off
REM Simple Database setup script for Vilara website

echo ====================================
echo Vilara Database Setup (Simplified)
echo ====================================
echo.

REM Force fresh authentication
echo Authenticating with GCP...
echo This will open a browser window for authentication.
gcloud auth login --force
echo.

REM Set project after login
echo Setting project to vilara-dev...
gcloud config set project vilara-dev

REM Test if it worked
echo.
echo Testing connection...
gcloud compute regions list --limit=1 >NUL 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Authentication or project access failed.
    echo Please make sure:
    echo 1. You logged in with tim@vilara.ai
    echo 2. The project vilara-dev exists
    echo 3. You have access to the project
    echo.
    echo Your current configuration:
    gcloud config list
    pause
    exit /b 1
)

echo SUCCESS! Authentication working.
echo.

REM Now do the database setup
set INSTANCE_NAME=vilara-dev-sql
set DATABASE_NAME=appdb
set DB_USER=appuser

echo Checking Cloud SQL instance...
gcloud sql instances describe %INSTANCE_NAME% >NUL 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Cloud SQL instance %INSTANCE_NAME% not found.
    echo.
    echo Available instances:
    gcloud sql instances list
    pause
    exit /b 1
)
echo Cloud SQL instance found: %INSTANCE_NAME%

echo.
echo Checking database...
gcloud sql databases list --instance=%INSTANCE_NAME% | findstr %DATABASE_NAME% >NUL
if %errorlevel%==0 (
    echo Database '%DATABASE_NAME%' exists
) else (
    echo Creating database '%DATABASE_NAME%'...
    gcloud sql databases create %DATABASE_NAME% --instance=%INSTANCE_NAME%
)

echo.
echo Checking user...
gcloud sql users list --instance=%INSTANCE_NAME% | findstr %DB_USER% >NUL
if %errorlevel%==0 (
    echo User '%DB_USER%' exists
) else (
    echo Creating user '%DB_USER%'...
    echo Please enter a password for the database user:
    set /p DB_PASSWORD=Password: 
    gcloud sql users create %DB_USER% --instance=%INSTANCE_NAME% --password=%DB_PASSWORD%
    
    echo Storing password in Secret Manager...
    echo %DB_PASSWORD% | gcloud secrets create db-appuser-password --data-file=- 2>NUL
    if %errorlevel% neq 0 (
        echo Secret already exists, updating...
        echo %DB_PASSWORD% | gcloud secrets versions add db-appuser-password --data-file=-
    )
)

echo.
echo Setting up SendGrid API key...
gcloud secrets describe sendgrid-api-key >NUL 2>&1
if %errorlevel% neq 0 (
    echo SendGrid API key secret not found.
    echo Please enter your SendGrid API key (or press Enter to skip):
    set /p SENDGRID_KEY=SendGrid API Key: 
    if not "%SENDGRID_KEY%"=="" (
        echo %SENDGRID_KEY% | gcloud secrets create sendgrid-api-key --data-file=-
    )
) else (
    echo SendGrid API key secret exists
)

echo.
echo ====================================
echo Setup Complete!
echo ====================================
echo.
echo Next: Import the database schema
echo.
echo Option 1: Use Cloud Console SQL Studio
echo   Go to: https://console.cloud.google.com/sql/instances/%INSTANCE_NAME%/databases/%DATABASE_NAME%/sql
echo   Then paste the contents of api/schema.sql
echo.
echo Option 2: Use Cloud Shell
echo   1. Go to: https://console.cloud.google.com
echo   2. Click the Cloud Shell icon (top right)
echo   3. Run: gcloud sql connect %INSTANCE_NAME% --user=%DB_USER% --database=%DATABASE_NAME%
echo   4. Paste the contents of api/schema.sql
echo.
pause