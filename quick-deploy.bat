@echo off
REM Quick deployment without authentication checks

echo ====================================
echo Vilara Quick Deploy
echo ====================================
echo.

echo Setting project to vilara-dev...
gcloud config set project vilara-dev

echo Building Docker image...
docker build -t us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest .

echo Pushing to registry...
docker push us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest

echo Deploying to Cloud Run...
gcloud run deploy website --image us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest --platform managed --region us-central1 --allow-unauthenticated --port 8080

echo Done!
pause