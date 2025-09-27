@echo off
REM Check if argument is given
if "%~1"=="" (
    echo Usage: %~nx0 text
    exit /b 1
)

REM Store first argument in variable
set "text=%~1"

REM Print the variable
dotnet new sln -n %text%
md Shared
md Platforms

dotnet new mglib -o Shared\%text%.Shared
dotnet new mgandroid -o Platforms\%text%.Android
dotnet new mgdesktopgl -o Platforms\%text%.DesktopGL
dotnet new mgios -o Platforms\%text%.iOS
dotnet new mgwindowsdx -o Platforms\%text%.WindowsDX

REM === Create Shared Content project in correct folder ===
md Shared\Content
xcopy /Y /I "Shared\%text%.Shared\Content\*" "Shared\Content\"


dotnet sln %text%.sln add Shared\%text%.Shared\%text%.Shared.csproj
dotnet sln %text%.sln add Platforms\%text%.Android --solution-folder Platforms
dotnet sln %text%.sln add Platforms\%text%.DesktopGL --solution-folder Platforms
dotnet sln %text%.sln add Platforms\%text%.iOS --solution-folder Platforms
dotnet sln %text%.sln add Platforms\%text%.WindowsDX --solution-folder Platforms

dotnet add Platforms\%text%.Android\%text%.Android.csproj reference Shared\%text%.Shared
dotnet add Platforms\%text%.DesktopGL\%text%.DesktopGL.csproj reference Shared\%text%.Shared
dotnet add Platforms\%text%.iOS\%text%.iOS.csproj reference Shared\%text%.Shared
dotnet add Platforms\%text%.WindowsDX\%text%.WindowsDX.csproj reference Shared\%text%.Shared

echo Linking shared Content.mgcb...

REM Inject shared Content.mgcb reference into all platform csproj files
for %%p in (Android DesktopGL iOS WindowsDX) do (
    call :AddContentRef "Platforms\%text%.%%p\%text%.%%p.csproj"
)



echo.
echo ============================================
echo Solution %text% created successfully!
echo Shared Content.mgcb is wired to all platforms.
echo ============================================
exit /b 0


:AddContentRef
REM Appends MonoGame content reference to a given csproj
(
  for /f "usebackq delims=" %%l in ("%~1") do (
    if "%%l"== "</Project>" (
        echo   ^<ItemGroup^>
        echo     ^<MonoGameContentReference Include="..\..\Shared\Content\Content.mgcb" /^>
        echo   ^</ItemGroup^>
    )
    echo %%l
  )
) > "%~1.tmp"
move /Y "%~1.tmp" "%~1" > nul
goto :eof