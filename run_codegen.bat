@echo off
REM TMS INFRA bindings
set TMS_INFRA=%cd%\tms-infra
set TMS_FLUTTER=%cd%\tms-client
set TMS_CRATES=crate::infra
set TMS_FLUTTER_ENTRY_NAME=TmsRustLib

REM codegen for flutter
flutter_rust_bridge_codegen generate --dart-entrypoint-class-name %TMS_FLUTTER_ENTRY_NAME% --rust-input %TMS_CRATES% --rust-root %TMS_INFRA% --dart-output %TMS_FLUTTER%\lib\generated
REM build wasm logic
wasm-pack build %TMS_INFRA% --target no-modules --out-dir %TMS_FLUTTER%\web\pkg --no-typescript --out-name tms_infra --dev -- -Z build-std=std,panic_abort
cd %TMS_FLUTTER% && dart run flutter_rust_bridge build-web --dart-root %TMS_FLUTTER% --rust-root %TMS_INFRA%