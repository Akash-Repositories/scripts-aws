@echo off
echo Starting Expo development environment...

REM Load environment variables if .env exists
if exist .env (
  for /f "tokens=*" %%a in (.env) do (
    set %%a
  )
)

REM Choose development mode
if "%1"=="docker" (
  REM Start development in Docker
  docker compose up expo-dev
) else if "%1"=="build" (
  REM Build for EAS
  npx eas-cli build --platform all --profile development
) else if "%1"=="publish" (
  REM Publish to Expo/EAS
  npx eas-cli update --auto
) else if "%1"=="zeego" (
  REM Initialize Zeego Cloud configuration
  echo Configuring Zeego Cloud integration...
  npx zeego init
) else (
  REM Start Expo development server locally
  npx expo start --dev-client
)
docker compose up -d database
if %errorlevel% neq 0 exit /b %errorlevel%
call npm install -g npm@latest --loglevel=error
call npm install --loglevel=error
call npm run build --prefix client --loglevel=error
call npx sequelize db:migrate
npm start
