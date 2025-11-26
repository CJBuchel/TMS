@echo off
REM TMS INFRA bindings

set TMS_INFRA=%cd%\tms_infra
set TMS_FLUTTER=%cd%\tms_client

REM codegen for flutter
echo Running codegen for %TMS_INFRA%
pushd "%TMS_FLUTTER%"
flutter_rust_bridge_codegen generate
if %errorlevel% neq 0 popd && exit /b %errorlevel%
popd

REM build wasm logic
echo Building wasm for %TMS_INFRA%
wasm-pack build "%TMS_INFRA%" --target no-modules --out-dir "%TMS_FLUTTER%\web\pkg" --no-typescript --out-name tms_infra --dev -- -Z build-std=std,panic_abort
if %errorlevel% neq 0 exit /b %errorlevel%

pushd "%TMS_FLUTTER%"
flutter_rust_bridge_codegen build-web --dart-root "%TMS_FLUTTER%" --rust-root "%TMS_INFRA%"
if %errorlevel% neq 0 popd && exit /b %errorlevel%
popd

REM run flutter code gen (freezed)
echo Running freezed for %TMS_FLUTTER%
pushd "%TMS_FLUTTER%"
flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 popd && exit /b %errorlevel%
popd

REM run android code gen
REM echo Running codegen for android
REM pushd "%TMS_INFRA%"
REM cargo ndk -o "%TMS_FLUTTER%\android\app\src\main\jniLibs" build
REM popd