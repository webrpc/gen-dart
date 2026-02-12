generate:
	webrpc-gen -schema=./service.ridl -target=../../ -client -out=flutter_app/lib/generated/sdk.dart
	webrpc-gen -schema=./service.ridl -target=golang -server -out=go_server/proto/server.gen.go
