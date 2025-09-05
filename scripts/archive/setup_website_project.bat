@echo off
echo ====================================
echo Vilara Website Project Setup
echo ====================================
echo.

REM Initialize git repository
echo Initializing Git repository...
git init
if %errorlevel% neq 0 (
    echo Git init failed. Make sure Git is installed.
    pause
    exit /b 1
)

REM Create folder structure
echo Creating folder structure...
mkdir assets 2>nul
mkdir css 2>nul
mkdir js 2>nul
mkdir components 2>nul

REM Copy presentation files
echo Copying presentation files...
copy "..\business docs\demo_deck\vilara presentation\vilara_presentation.html" "demo.html" 2>nul
if %errorlevel% equ 0 (
    echo - Presentation copied as demo.html
) else (
    echo - Warning: Could not copy presentation file
)

copy "..\business docs\demo_deck\vilara presentation\Vilara_logo_transparent.png" "assets\Vilara_logo_transparent.png" 2>nul
if %errorlevel% equ 0 (
    echo - Logo copied to assets folder
) else (
    echo - Warning: Could not copy logo file
)

REM Create .gitignore
echo Creating .gitignore...
(
echo # Dependencies
echo node_modules/
echo.
echo # Environment variables
echo .env
echo .env.local
echo.
echo # IDE files
echo .vscode/
echo .idea/
echo *.swp
echo *.swo
echo.
echo # OS files
echo .DS_Store
echo Thumbs.db
echo.
echo # Build outputs
echo dist/
echo build/
echo.
echo # Logs
echo *.log
echo npm-debug.log*
echo.
echo # Deployment
echo .vercel/
echo .netlify/
) > .gitignore

REM Create README.md
echo Creating README.md...
(
echo # Vilara.ai Website
echo.
echo ## Overview
echo Official website for Vilara - The AI-augmented ERP system that adapts instantly.
echo.
echo ## Project Structure
echo ```
echo vilara-website/
echo ├── index.html          # Homepage
echo ├── demo.html           # Interactive presentation/demo
echo ├── assets/             # Images, logos, icons
echo ├── css/                # Stylesheets
echo ├── js/                 # JavaScript files
echo └── components/         # Reusable HTML components
echo ```
echo.
echo ## Development
echo 1. Open in VS Code: `code .`
echo 2. Use Live Server extension for local development
echo 3. Make changes and test locally
echo.
echo ## Deployment
echo ### Vercel
echo ```bash
echo npx vercel --prod
echo ```
echo.
echo ### Netlify
echo Drag and drop the folder to netlify.com/drop
echo.
echo ## Key Features
echo - Interactive demo presentation
echo - ROI calculator
echo - Three customer paths: Augment, Replace, or Start Fresh
echo - Natural language command examples
echo - Enterprise-ready design
echo.
echo ## Brand Colors
echo - Primary: #667eea to #764ba2 ^(gradient^)
echo - Success: #10b981
echo - Warning: #f59e0b
echo - Error: #ef4444
) > README.md

REM Create package.json for Vercel
echo Creating package.json...
(
echo {
echo   "name": "vilara-website",
echo   "version": "1.0.0",
echo   "description": "Vilara.ai - The AI-augmented ERP system",
echo   "scripts": {
echo     "dev": "live-server",
echo     "deploy": "vercel --prod"
echo   },
echo   "keywords": ["ERP", "AI", "Business", "Automation"],
echo   "author": "Vilara",
echo   "license": "UNLICENSED"
echo }
) > package.json

REM Create vercel.json for configuration
echo Creating vercel.json...
(
echo {
echo   "cleanUrls": true,
echo   "trailingSlash": false,
echo   "rewrites": [
echo     { "source": "/demo", "destination": "/demo.html" }
echo   ]
echo }
) > vercel.json

REM Initial git commit
echo.
echo Adding files to git...
git add .
git commit -m "Initial setup: Vilara website project structure"

echo.
echo ====================================
echo Setup Complete!
echo ====================================
echo.
echo Next steps:
echo 1. Open VS Code in this folder: code .
echo 2. Start new Claude session with the prompt file
echo 3. Begin website development
echo.
echo Files created:
echo - Project structure with folders
echo - .gitignore for clean repository
echo - README.md with documentation
echo - package.json for deployment
echo - vercel.json for URL configuration
echo - demo.html ^(copied from presentation^)
echo - Logo in assets folder
echo.
pause