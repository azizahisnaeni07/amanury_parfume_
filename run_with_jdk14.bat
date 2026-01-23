@echo off
set "JAVA_HOME=C:\Program Files\Java\jdk-14.0.2"
set "PATH=%JAVA_HOME%\bin;%PATH%"
echo Using JDK from: %JAVA_HOME%
flutter run
pause
