@echo off
REM Simple deployment script for Vilara website to Google Cloud Run

echo ====================================
echo Vilara Website Deployment (Simplified)
echo ====================================
echo.

REM Set variables
set PROJECT_ID=vilara-dev
set REGION=us-central1
set SERVICE_NAME=website
set REPO_NAME=vilara-docker
set IMAGE_NAME=website

REM Ensure authentication
echo Ensuring authentication...
gcloud auth list | findstr ACTIVE >NUL
if %errorlevel% neq 0 (
    echo You need to login first.
    gcloud auth login --force
)

echo Setting project...
gcloud config set project %PROJECT_ID%

echo.
echo Testing authentication...
gcloud compute regions list --limit=1 >NUL 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Authentication failed. Please run: gcloud auth login --force
    pause
    exit /b 1
)

echo.
echo Step 1: Creating Artifact Registry repository (if needed)...
gcloud artifacts repositories describe %REPO_NAME% --location=%REGION% >NUL 2>&1
if %errorlevel% neq 0 (
    echo Creating repository...
    gcloud artifacts repositories create %REPO_NAME% ^
        --repository-format=docker ^
        --location=%REGION% ^
        --description="Vilara website Docker images"
) else (
    echo Repository already exists
)

echo.
echo Step 2: Configuring Docker authentication...
call gcloud auth configure-docker %REGION%-docker.pkg.dev --quiet

echo.
echo Step 3: Building Docker image...
echo This may take a few minutes...
docker build -t %REGION%-docker.pkg.dev/%PROJECT_ID%/%REPO_NAME%/%IMAGE_NAME%:latest .
if %errorlevel% neq 0 (
    echo ERROR: Docker build failed
    echo Make sure Docker Desktop is running
    pause
    exit /b 1
)

echo.
echo Step 4: Pushing image to Artifact Registry...
docker push %REGION%-docker.pkg.dev/%PROJECT_ID%/%REPO_NAME%/%IMAGE_NAME%:latest
if %errorlevel% neq 0 (
    echo ERROR: Docker push failed
    pause
    exit /b 1
)

echo.
echo Step 5: Getting Cloud SQL connection name...
for /f "tokens=*" %%i in ('gcloud sql instances describe vilara-dev-sql --format="value(connectionName)" 2^>NUL') do set CONN=%%i
if "%CONN%"=="" (
    echo WARNING: Cloud SQL instance not found. Deployment will continue without database.
    set CONN=none
) else (
    echo Cloud SQL connection: %CONN%
)

echo.
echo Step 6: Deploying to Cloud Run...
if "%CONN%"=="none" (
    gcloud run deploy %SERVICE_NAME% ^
        --image %REGION%-docker.pkg.dev/%PROJECT_ID%/%REPO_NAME%/%IMAGE_NAME%:latest ^
        --platform managed ^
        --region %REGION% ^
        --allow-unauthenticated ^
        --memory 512Mi ^
        --cpu 1 ^
        --timeout 60 ^
        --concurrency 80 ^
        --max-instances 100 ^
        --port 8080
) else (
    gcloud run deploy %SERVICE_NAME% ^
        --image %REGION%-docker.pkg.dev/%PROJECT_ID%/%REPO_NAME%/%IMAGE_NAME%:latest ^
        --platform managed ^
        --region %REGION% ^
        --add-cloudsql-instances %CONN% ^
        --set-env-vars DB_HOST=/cloudsql/%CONN% ^
        --set-env-vars DB_NAME=appdb ^
        --set-env-vars DB_USER=appuser ^
        --set-env-vars DB_PORT=5432 ^
        --update-secrets DB_PASSWORD=db-appuser-password:latest ^
        --update-secrets SENDGRID_API_KEY=sendgrid-api-key:latest ^
        --allow-unauthenticated ^
        --memory 512Mi ^
        --cpu 1 ^
        --timeout 60 ^
        --concurrency 80 ^
        --max-instances 100 ^
        --port 8080
)

if %errorlevel% neq 0 (
    echo ERROR: Cloud Run deployment failed
    pause
    exit /b 1
)

echo.
echo Step 7: Getting service URL...
for /f "tokens=*" %%i in ('gcloud run services describe %SERVICE_NAME% --region=%REGION% --format="value(status.url)"') do set SERVICE_URL=%%i

echo.
echo ====================================
echo Deployment Complete!
echo ====================================
echo Service URL: %SERVICE_URL%
echo.
echo Test your endpoints:
echo   POST %SERVICE_URL%/api/universal-signup.php
echo   GET  %SERVICE_URL%/api/activate.php?token=xxx
echo.
pause