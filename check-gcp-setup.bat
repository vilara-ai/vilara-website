@echo off
REM Quick GCP environment check script

echo ====================================
echo GCP Environment Check
echo ====================================
echo.

echo Current Configuration:
echo ----------------------
echo Active Account:
gcloud config get-value account
echo.
echo Active Project:
gcloud config get-value project
echo.

echo Available Accounts:
echo -------------------
gcloud auth list
echo.

echo Testing Authentication:
echo ----------------------
gcloud auth application-default print-access-token >NUL 2>&1
if %errorlevel%==0 (
    echo [OK] Application default credentials configured
) else (
    echo [!] No application default credentials
    echo     Run: gcloud auth application-default login
)
echo.

echo Checking Project Access:
echo -----------------------
gcloud projects describe vilara-dev >NUL 2>&1
if %errorlevel%==0 (
    echo [OK] vilara-dev project accessible
    echo.
    echo Project Details:
    gcloud projects describe vilara-dev --format="table(projectId,projectNumber,name,createTime)"
) else (
    echo [!] Cannot access vilara-dev project
    echo.
    echo Available Projects:
    gcloud projects list --format="table(projectId,name)" 2>NUL
    if %errorlevel% neq 0 (
        echo.
        echo [ERROR] Cannot list projects. Please authenticate first:
        echo         gcloud auth login tim@vilara.ai
    )
)
echo.

echo Quick Fix Commands:
echo ------------------
echo 1. Login to GCP:
echo    gcloud auth login tim@vilara.ai
echo.
echo 2. Set project:
echo    gcloud config set project vilara-dev
echo.
echo 3. Setup application default credentials:
echo    gcloud auth application-default login
echo.
echo 4. Configure Docker:
echo    gcloud auth configure-docker us-central1-docker.pkg.dev
echo.

pause