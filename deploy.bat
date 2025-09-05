@echo off
REM Deployment script for Vilara website to Google Cloud Run
REM Run from Windows Command Prompt

echo ====================================
echo Vilara Website Deployment Script
echo ====================================
echo.

REM Set environment variables
set PROJECT_ID=vilara-dev
set REGION=us-central1
set SERVICE_NAME=website
set REPO_NAME=vilara-docker
set IMAGE_NAME=website

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

REM Create Artifact Registry repository if it doesn't exist
echo.
echo Step 2: Creating Artifact Registry repository...
gcloud artifacts repositories create %REPO_NAME% --repository-format=docker --location=%REGION% --description="Vilara website Docker images" 2>NUL
if %errorlevel%==0 (
    echo Repository created successfully
) else (
    echo Repository already exists or error occurred
)

REM Configure Docker authentication
echo.
echo Step 3: Configuring Docker authentication...
gcloud auth configure-docker %REGION%-docker.pkg.dev

REM Build the Docker image
echo.
echo Step 4: Building Docker image...
docker build -t %REGION%-docker.pkg.dev/%PROJECT_ID%/%REPO_NAME%/%IMAGE_NAME%:latest .
if %errorlevel% neq 0 (
    echo Error: Docker build failed
    exit /b 1
)

REM Push to Artifact Registry
echo.
echo Step 5: Pushing image to Artifact Registry...
docker push %REGION%-docker.pkg.dev/%PROJECT_ID%/%REPO_NAME%/%IMAGE_NAME%:latest
if %errorlevel% neq 0 (
    echo Error: Docker push failed
    exit /b 1
)

REM Get Cloud SQL connection name
echo.
echo Step 6: Getting Cloud SQL connection details...
for /f "tokens=*" %%i in ('gcloud sql instances describe vilara-dev-sql --format="value(connectionName)"') do set CONN=%%i
echo Cloud SQL connection: %CONN%

REM Deploy to Cloud Run
echo.
echo Step 7: Deploying to Cloud Run...
gcloud run deploy %SERVICE_NAME% ^
    --image %REGION%-docker.pkg.dev/%PROJECT_ID%/%REPO_NAME%/%IMAGE_NAME%:latest ^
    --platform managed ^
    --region %REGION% ^
    --add-cloudsql-instances %CONN% ^
    --set-env-vars DB_HOST=/cloudsql/%CONN% ^
    --set-env-vars DB_NAME=appdb ^
    --set-env-vars DB_USER=appuser ^
    --set-env-vars DB_PORT=5432 ^
    --set-secrets DB_PASSWORD=db-appuser-password:latest ^
    --set-secrets SENDGRID_API_KEY=sendgrid-api-key:latest ^
    --allow-unauthenticated ^
    --memory 512Mi ^
    --cpu 1 ^
    --timeout 60 ^
    --concurrency 80 ^
    --max-instances 100

if %errorlevel% neq 0 (
    echo Error: Cloud Run deployment failed
    exit /b 1
)

REM Get service URL
echo.
echo Step 8: Getting service URL...
for /f "tokens=*" %%i in ('gcloud run services describe %SERVICE_NAME% --region=%REGION% --format="value(status.url)"') do set SERVICE_URL=%%i
echo.
echo ====================================
echo Deployment Complete!
echo Service URL: %SERVICE_URL%
echo ====================================
echo.
echo Next steps:
echo 1. Update your DNS to point to this URL
echo 2. Test the API endpoints:
echo    - POST %SERVICE_URL%/api/universal-signup.php
echo    - GET %SERVICE_URL%/api/activate.php?token=xxx
echo.
pause