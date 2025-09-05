@echo off
echo ====================================
echo Step by Step Deployment
echo ====================================
echo.

echo Setting project...
gcloud config set project vilara-dev
echo.

echo Press any key to continue to enable APIs...
pause

echo Enabling Cloud Build API...
gcloud services enable cloudbuild.googleapis.com

echo Enabling Artifact Registry API...
gcloud services enable artifactregistry.googleapis.com  

echo Enabling Cloud Run API...
gcloud services enable run.googleapis.com

echo.
echo Press any key to continue to set permissions...
pause

echo Getting project info...
gcloud projects describe vilara-dev

echo Setting Cloud Build permissions...
gcloud projects add-iam-policy-binding vilara-dev --member=serviceAccount:1040930643556@cloudbuild.gserviceaccount.com --role=roles/artifactregistry.writer

echo.
echo Press any key to continue to create repository...
pause

echo Creating repository...
gcloud artifacts repositories create vilara-docker --repository-format=docker --location=us-central1

echo.
echo Press any key to start build...
pause

echo Building image...
gcloud builds submit --tag us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest .

echo.
echo Done! Check results above.
pause