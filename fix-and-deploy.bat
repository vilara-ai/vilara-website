@echo off
REM Fix permissions and deploy

echo ====================================
echo Fixing Permissions and Deploying
echo ====================================
echo.

echo Setting project...
gcloud config set project vilara-dev

echo.
echo Step 1: Enabling required APIs...
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable run.googleapis.com

echo.
echo Step 2: Getting project number...
for /f "tokens=*" %%i in ('gcloud projects describe vilara-dev --format="value(projectNumber)"') do set PROJECT_NUMBER=%%i
echo Project number: %PROJECT_NUMBER%

echo.
echo Step 3: Setting Cloud Build permissions...
gcloud projects add-iam-policy-binding vilara-dev ^
    --member=serviceAccount:%PROJECT_NUMBER%@cloudbuild.gserviceaccount.com ^
    --role=roles/artifactregistry.writer

gcloud projects add-iam-policy-binding vilara-dev ^
    --member=serviceAccount:%PROJECT_NUMBER%@cloudbuild.gserviceaccount.com ^
    --role=roles/run.admin

gcloud projects add-iam-policy-binding vilara-dev ^
    --member=serviceAccount:%PROJECT_NUMBER%@cloudbuild.gserviceaccount.com ^
    --role=roles/iam.serviceAccountUser

echo.
echo Step 4: Creating Artifact Registry repository...
gcloud artifacts repositories create vilara-docker ^
    --repository-format=docker ^
    --location=us-central1 ^
    --description="Vilara website images" 2>NUL
if %errorlevel%==0 (
    echo Repository created
) else (
    echo Repository already exists
)

echo.
echo Step 5: Building with Cloud Build...
gcloud builds submit --tag us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest .

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Build still failed. Let's try a different approach...
    echo.
    echo Checking if repository exists...
    gcloud artifacts repositories describe vilara-docker --location=us-central1
    echo.
    echo Checking Cloud Build service account permissions...
    gcloud projects get-iam-policy vilara-dev --flatten="bindings[].members" --filter="bindings.members:%PROJECT_NUMBER%@cloudbuild.gserviceaccount.com"
    pause
    exit /b 1
)

echo.
echo Step 6: Deploying to Cloud Run...
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
    echo ERROR: Deployment failed
    pause
    exit /b 1
)

echo.
echo Getting service URL...
for /f "tokens=*" %%i in ('gcloud run services describe website --region=us-central1 --format="value(status.url)"') do set URL=%%i

echo.
echo ====================================
echo SUCCESS! DEPLOYMENT COMPLETE!
echo ====================================
echo Service URL: %URL%
echo.
echo Test your API:
echo curl -X POST %URL%/api/universal-signup.php
echo.
pause