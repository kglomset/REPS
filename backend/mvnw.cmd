@REM Maven wrapper script (Windows)
@echo off
setlocal

set MAVEN_WRAPPER_JAR=.mvn\wrapper\maven-wrapper.jar
set MAVEN_WRAPPER_PROPERTIES=.mvn\wrapper\maven-wrapper.properties
set MAVEN_PROJECTBASEDIR=%~dp0

if not exist "%MAVEN_WRAPPER_JAR%" (
    for /f "tokens=2 delims==" %%a in ('findstr "wrapperUrl" "%MAVEN_WRAPPER_PROPERTIES%"') do set WRAPPER_URL=%%a
    echo Downloading Maven Wrapper from %WRAPPER_URL%
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%WRAPPER_URL%', '%MAVEN_WRAPPER_JAR%')"
)

set JAVA_CMD=java
if defined JAVA_HOME set JAVA_CMD=%JAVA_HOME%\bin\java

"%JAVA_CMD%" -classpath "%MAVEN_WRAPPER_JAR%" ^
  "-Dmaven.multiModuleProjectDirectory=%MAVEN_PROJECTBASEDIR%" ^
  org.apache.maven.wrapper.MavenWrapperMain %*
