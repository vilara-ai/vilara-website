@echo off
REM Combined auth and deployment script

echo ====================================
echo Vilara Website - Auth and Deploy
echo ====================================
echo.

REM Step 1: Force authentication
echo Step 1: Authenticating...
echo.
echo This will open your browser for Google login.
echo Please login with tim@vilara.ai
echo.
pause
gcloud auth login

REM Step 2: Set the project
echo.
echo Step 2: Setting project...
gcloud config set project vilara-dev

REM Step 3: Verify it worked
echo.
echo Step 3: Verifying access...
gcloud projects describe vilara-dev
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Cannot access project vilara-dev
    echo Please check:
    echo 1. You logged in with the correct account
    echo 2. The project name is correct
    echo.
    echo Your config:
    gcloud config list
    pause
    exit /b 1
)

echo.
echo SUCCESS! Authentication complete.
echo.

REM Step 4: Configure Docker auth
echo Step 4: Configuring Docker...
call gcloud auth configure-docker us-central1-docker.pkg.dev --quiet

REM Step 5: Build the image
echo.
echo Step 5: Building Docker image...
docker build -t us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest .
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Docker build failed
    echo Is Docker Desktop running?
    pause
    exit /b 1
)

REM Step 6: Create repository if needed
echo.
echo Step 6: Creating Artifact Registry repository...
gcloud artifacts repositories create vilara-docker --repository-format=docker --location=us-central1 2>NUL
if %errorlevel%==0 (
    echo Repository created
) else (
    echo Repository exists or cannot be created
)

REM Step 7: Push the image
echo.
echo Step 7: Pushing to Artifact Registry...
docker push us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Push failed. Trying to fix authentication...
    gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://us-central1-docker.pkg.dev
    docker push us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest
)

REM Step 8: Deploy to Cloud Run
echo.
echo Step 8: Deploying to Cloud Run...
gcloud run deploy website ^
    --image us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest ^
    --platform managed ^
    --region us-central1 ^
    --allow-unauthenticated ^
    --port 8080

echo.
echo ====================================
echo DEPLOYMENT COMPLETE!
echo ====================================
echo.
echo Your service should be running. Check the URL above.
echo.
pause