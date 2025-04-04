@echo off
setlocal enabledelayedexpansion

REM Set default variables
if not defined AWS_REGION set AWS_REGION=us-east-1
if not defined AWS_PROFILE set AWS_PROFILE=default

REM Parse command line arguments
set BUILD=false
set DEPLOY=false
set PUBLISH=false

:parse_args
if "%~1"=="" goto execute
if "%~1"=="--build" set BUILD=true
if "%~1"=="--deploy" set DEPLOY=true
if "%~1"=="--publish" set PUBLISH=true
if "%~1"=="--help" goto display_usage
shift
goto parse_args

:display_usage
echo Usage: %0 [options]
echo Options:
echo   --build          Build the application
echo   --deploy         Deploy to AWS
echo   --publish        Publish to Expo
echo   --help           Display this help message
exit /b 0

:execute
REM Build the application
if "%BUILD%"=="true" (
  echo Building application...
  call npx eas-cli build --platform all --profile production --non-interactive
)

REM Deploy to AWS
if "%DEPLOY%"=="true" (
  echo Deploying to AWS...
  call aws s3 sync ./build s3://your-bucket-name/ --profile %AWS_PROFILE%
  
  REM If using CloudFront, invalidate cache
  if defined CLOUDFRONT_DISTRIBUTION_ID (
    call aws cloudfront create-invalidation --distribution-id %CLOUDFRONT_DISTRIBUTION_ID% --paths "/*" --profile %AWS_PROFILE%
  )
)

REM Publish to Expo
if "%PUBLISH%"=="true" (
  echo Publishing to Expo...
  call npx eas-cli update --auto
)

echo Deployment process completed!
exit /b 0