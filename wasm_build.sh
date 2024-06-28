# script to run wasm build
# rustup default nightly
# wasm-pack build ./tms-infra --target no-modules --out-dir $(pwd)/tms-client/web/pkg --no-typescript --out-name tms_infra --dev
# wasm-pack build -t no-modules -d $(pwd)/tms-client/web/pkg --no-typescript --out-name tms_infra --dev $(pwd)/tms-infra
# -- -Z build-std=std,panic_abort
# rustup default stable

# temprarily run command within tms-client
TMS_INFRA=$(pwd)/tms-infra-logic
TMS_CLIENT=$(pwd)/tms-client
wasm-pack build $TMS_INFRA --target no-modules --out-dir $TMS_CLIENT/web/pkg --no-typescript --out-name tms_infra --dev -- -Z build-std=std,panic_abort
(cd tms-client && dart run flutter_rust_bridge build-web --dart-root $TMS_CLIENT --rust-root $TMS_INFRA)