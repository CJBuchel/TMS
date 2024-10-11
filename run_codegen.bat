# colors
$R = "`e[0;31m"   # '0;31' is Red's ANSI color code
$G = "`e[0;32m"   # '0;32' is Green's ANSI color code
$Y = "`e[1;32m"   # '1;32' is Yellow's ANSI color code
$B = "`e[0;34m"   # '0;34' is Blue's ANSI color code

#
# TMS INFRA bindings
#
$TMS_INFRA = (Get-Location).Path + "\tms-infra"
$TMS_FLUTTER = (Get-Location).Path + "\tms-client"
$TMS_CRATES = "crate::infra"
$TMS_FLUTTER_ENTRY_NAME = "TmsRustLib"

# codegen for flutter (green text)
Write-Host "${G}Running codegen for $TMS_INFRA"
flutter_rust_bridge_codegen generate --dart-entrypoint-class-name $TMS_FLUTTER_ENTRY_NAME --rust-input $TMS_CRATES --rust-root $TMS_INFRA --dart-output $TMS_FLUTTER\lib\generated

# build wasm logic
Write-Host "${G}Building wasm for $TMS_INFRA"
wasm-pack build $TMS_INFRA --target no-modules --out-dir $TMS_FLUTTER\web\pkg --no-typescript --out-name tms_infra --dev -- -Z build-std=std,panic_abort
cd $TMS_FLUTTER
dart run flutter_rust_bridge build-web --dart-root $TMS_FLUTTER --rust-root $TMS_INFRA
cd ..

# run flutter code gen (freezed)
Write-Host "${G}Running freezed for $TMS_FLUTTER"
cd $TMS_FLUTTER
flutter pub run build_runner build --delete-conflicting-outputs
cd ..

# run android code gen
Write-Host "${G}Running codegen for android"
cd $TMS_INFRA
cargo ndk -o $TMS_FLUTTER\android\app\src\main\jniLibs build
cd ..