@echo off
echo Building Docker image...
docker build -t vilara-website .
echo Build complete - check for errors above
pause

echo Tagging for GCP...
docker tag vilara-website us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest
echo Tag complete
pause

echo Pushing to GCP...
docker push us-central1-docker.pkg.dev/vilara-dev/vilara-docker/website:latest
echo Push complete
pause