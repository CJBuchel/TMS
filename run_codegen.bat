@echo off
REM temporarily run command within tms-client
set TMS_INFRA=%cd%\tms-infra
set TMS_CLIENT=%cd%\tms-client
REM codegen for flutter
call flutter_rust_bridge_codegen generate --rust-input crate::api --rust-root %TMS_INFRA% --dart-output %TMS_CLIENT%\lib\generated
REM build wasm logic
call wasm-pack build %TMS_INFRA% --target no-modules --out-dir %TMS_CLIENT%\web\pkg --no-typescript --out-name tms_infra --dev
cd %TMS_CLIENT% && call dart run flutter_rust_bridge build-web --dart-root %TMS_CLIENT% --rust-root %TMS_INFRA%