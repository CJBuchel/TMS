protoc --proto_path=protos --dart_out=grpc:client/lib/generated protos/common/*.proto protos/api/*.proto protos/db/*.proto
cd client && dart run build_runner build --delete-conflicting-outputs
