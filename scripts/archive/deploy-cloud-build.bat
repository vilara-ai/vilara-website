@echo off
REM Deploy using Google Cloud Build (no local Docker needed)

echo ====================================
echo Vilara Deploy via Cloud Build
echo ====================================
echo.

echo Setting project...
gcloud config set project vilara-dev

echo.
echo Creating Artifact Registry repository if needed...
gcloud artifacts repositories create vilara-docker --repository-format=docker --location=us-central1 --description="Vilara website images" 2>NUL

echo.
echo Building image using Cloud Build...
echo This builds the Docker image on Google Cloud, no local Docker needed.
gcloud builds submit --tag us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest .

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Cloud Build failed
    pause
    exit /b 1
)

echo.
echo Deploying to Cloud Run...
gcloud run deploy website ^
    --image us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest ^
    --platform managed ^
    --region us-central1 ^
    --allow-unauthenticated ^
    --port 8080 ^
    --memory 512Mi ^
    --cpu 1

echo.
echo Getting service URL...
for /f "tokens=*" %%i in ('gcloud run services describe website --region=us-central1 --format="value(status.url)"') do set URL=%%i

echo.
echo ====================================
echo DEPLOYMENT COMPLETE!
echo ====================================
echo Service URL: %URL%
echo.
pause