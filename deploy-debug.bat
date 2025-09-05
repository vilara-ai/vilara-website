@echo off
REM Debug deployment script

echo ====================================
echo Vilara Deploy (Debug Mode)
echo ====================================
echo.

echo 1. Setting project...
gcloud config set project vilara-dev
echo    Done!
echo.

echo 2. Checking Docker...
docker --version
if %errorlevel% neq 0 (
    echo    ERROR: Docker not found
    echo    Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo    Docker found!
echo.

echo 3. Testing Docker is running...
docker ps >NUL 2>&1
if %errorlevel% neq 0 (
    echo    ERROR: Docker is not running
    echo    Please start Docker Desktop
    pause
    exit /b 1
)
echo    Docker is running!
echo.

echo 4. Configuring Docker for GCP...
call gcloud auth configure-docker us-central1-docker.pkg.dev --quiet
echo    Done!
echo.

echo 5. Building Docker image...
echo    Running: docker build -t us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest .
docker build -t us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest .
if %errorlevel% neq 0 (
    echo.
    echo    ERROR: Docker build failed
    echo    Check the error messages above
    pause
    exit /b 1
)
echo    Build successful!
echo.

echo 6. Creating Artifact Registry repository if needed...
gcloud artifacts repositories describe vilara-docker --location=us-central1 >NUL 2>&1
if %errorlevel% neq 0 (
    echo    Creating repository...
    gcloud artifacts repositories create vilara-docker --repository-format=docker --location=us-central1 --description="Vilara website images"
) else (
    echo    Repository already exists
)
echo.

echo 7. Pushing image to registry...
echo    This may take a few minutes...
docker push us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest
if %errorlevel% neq 0 (
    echo.
    echo    ERROR: Push failed
    echo    Trying alternative authentication...
    for /f "tokens=*" %%i in ('gcloud auth print-access-token') do set TOKEN=%%i
    echo %TOKEN% | docker login -u oauth2accesstoken --password-stdin https://us-central1-docker.pkg.dev
    docker push us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest
    if %errorlevel% neq 0 (
        echo    Still failing. Check your permissions.
        pause
        exit /b 1
    )
)
echo    Push successful!
echo.

echo 8. Deploying to Cloud Run...
gcloud run deploy website ^
    --image us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest ^
    --platform managed ^
    --region us-central1 ^
    --allow-unauthenticated ^
    --port 8080 ^
    --memory 512Mi ^
    --cpu 1
if %errorlevel% neq 0 (
    echo.
    echo    ERROR: Deployment failed
    pause
    exit /b 1
)

echo.
echo 9. Getting service URL...
for /f "tokens=*" %%i in ('gcloud run services describe website --region=us-central1 --format="value(status.url)"') do set URL=%%i
echo.
echo ====================================
echo DEPLOYMENT SUCCESSFUL!
echo ====================================
echo Service URL: %URL%
echo.
echo Test your API:
echo   curl -X POST %URL%/api/universal-signup.php
echo.
pause