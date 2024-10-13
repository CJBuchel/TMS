@echo off

REM colors
set "R="
set "G="
set "Y="
set "B="

REM TMS INFRA bindings
set "TMS_INFRA=%cd%\tms-infra"
set "TMS_FLUTTER=%cd%\tms-client"
set "TMS_CRATES=crate::infra"
set "TMS_FLUTTER_ENTRY_NAME=TmsRustLib"

REM codegen for flutter (green text)
echo Running codegen for %TMS_INFRA%
flutter_rust_bridge_codegen generate --dart-entrypoint-class-name %TMS_FLUTTER_ENTRY_NAME% --rust-input %TMS_CRATES% --rust-root %TMS_INFRA% --dart-output %TMS_FLUTTER%\lib\generated

REM build wasm logic
echo Building wasm for %TMS_INFRA%
wasm-pack build %TMS_INFRA% --target no-modules --out-dir %TMS_FLUTTER%\web\pkg --no-typescript --out-name tms_infra --dev -- -Z build-std=std,panic_abort
cd %TMS_FLUTTER%
dart run flutter_rust_bridge build-web --dart-root %TMS_FLUTTER% --rust-root %TMS_INFRA%
cd ..

REM run flutter code gen (freezed)
echo Running freezed for %TMS_FLUTTER%
cd %TMS_FLUTTER%
flutter pub run build_runner build --delete-conflicting-outputs
cd ..

REM run android code gen
echo Running codegen for android
cd %TMS_INFRA%
cargo ndk -o %TMS_FLUTTER%\android\app\src\main\jniLibs build
cd ..