@ECHO OFF

SET MY_DIR=%~dp0
SET MVN_SETTINGS_FILE_NAME=imagic_mvn_settings.xml
SET MVN_SETTINGS_FILE=%MY_DIR%%MVN_SETTINGS_FILE_NAME%
SET MVN_POM_FILE_NAME=imagic_pom.xml
SET MVN_POM_FILE=%MY_DIR%%MVN_POM_FILE_NAME%

SET MVN_PROFILE=imagicIntern


IF NOT EXIST "%MVN_POM_FILE%" (
    ECHO ===========================================================================
    ECHO = Could not find imagic pom! Searched:
    ECHO = %MVN_POM_FILE%
    ECHO = Maybe you are on the wrong Git branch?
    ECHO = Going to abort now...
    ECHO ===========================================================================
    GOTO ERROR
)


IF NOT EXIST "%MVN_SETTINGS_FILE%" (
    GOTO WRITE_STUB
) ELSE (
    GOTO DEPLOY
)


:WRITE_STUB
    ECHO ===========================================================================
    ECHO = Could not find the needed maven settings.xml for this script! Should be  
    ECHO = here: %MVN_SETTINGS_FILE%                                                
    ECHO = I'll go to create a stub of the file where you afterwards can replace    
    ECHO = the content inside the ^[^] with your user name (used for Artifactory)   
    ECHO = and also your encrypted API Key which you already have in your           
    ECHO = %HOME%\.gradle\gradle.properties file (retrieved from Artifactory)!      
    ECHO ===========================================================================
    ( ECHO ^<settings^>
    ECHO   ^<servers^>
    ECHO     ^<server^>
    ECHO       ^<username^>[username]^</username^>
    ECHO       ^<password^>[api_key]^</password^>
    ECHO       ^<id^>extReleaseLocal^</id^>
    ECHO     ^</server^>
    ECHO     ^<server^>
    ECHO       ^<username^>[username]^</username^>
    ECHO       ^<password^>[api_key]^</password^>
    ECHO       ^<id^>extSnapshotLocal^</id^>
    ECHO     ^</server^>
    ECHO   ^</servers^>
    ECHO ^</settings^>
    ECHO. ) > %MVN_SETTINGS_FILE%
    SLEEP 2
    notepad %MVN_SETTINGS_FILE%
    IF NOT ERRORLEVEL 0 GOTO ERROR


:DEPLOY
IF NOT DEFINED JAVA_HOME (
    ECHO ===========================================================================
    ECHO = The env variable JAVA_HOME is not defined but maybe needed by Maven!     
    ECHO = If this script does throw such related errors you know what to do.       
    ECHO ===========================================================================
)


PUSHD %MY_DIR%
ECHO =========================================================================================================================================
ECHO = Going to execute maven with the following command:
ECHO = mvn -f %MVN_POM_FILE% --settings %MVN_SETTINGS_FILE% -P %MVN_PROFILE% %*
ECHO =========================================================================================================================================

REM SET JAVA_HOME=C:\Program Files\Java\jdk1.8.0_144& mvn -f imagic_pom.xml --settings imagic_mvn_settings.xml deploy -P imagicIntern

mvn -f %MVN_POM_FILE% --settings %MVN_SETTINGS_FILE% -P %MVN_PROFILE% %*
IF NOT ERRORLEVEL 1 GOTO END

:ERROR
ECHO ===========================================================================
ECHO = An error happend! An error happend! An error happend! An error happend! =
ECHO ===========================================================================


:END
POPD
