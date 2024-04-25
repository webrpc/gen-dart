# flutter-go
An example full-stack app using Flutter as the frontend and a minimal golang server as the backend.

## Structure

| Path                                                | Description |
| --------------------------------------------------- | ---------- |
| [service.ridl](./service.ridl) | webrpc service schema (types, endpoints, and errors); shared between client and server. |
| [flutter_app/](./flutter_app/) | frontend Flutter app (tested on Web only) |
| [flutter_app/lib/main.dart](./flutter_app/lib/main.dart) | flutter app entry-point |
| [flutter_app/lib/generated/sdk.dart](./flutter_app/lib/generated/sdk.dart) | generated client code |
| [flutter_app/lib/dev/mock_sdk.dart](./flutter_app/lib/dev/mock_sdk.dart) | example of mocking the service for development and testing |
| [flutter_app/lib/src/sample_feature/*](./flutter_app/lib/src/sample_feature/) | widgets using the generated client |
| [flutter_app/test/widget_test.dart](./flutter_app/test/widget_test.dart) | tests of widgets using the generated client |
| [go_server/](./go_server/) | Backend server |

## Try it out
Start the server (after installing Go).
```bash
cd go_server
SERVICE_PORT=3333 go run main.go
```

Start the client (after installing Flutter).
```bash
cd flutter_app
flutter run -d chrome --dart-define=SERVICE=real --dart-define=SERVICE_HOSTNAME=http://localhost:3333
```

## Make changes
Try updating the service schema and re-generating the client and server code.

To generate the client
```bash
path/to/webrpc-gen -schema=./service.ridl -target=../../ -client -out=flutter_app/lib/generated/sdk.dart
```

To generate the server
```bash
path/to/webrpc-gen -schema=./service.ridl -target=golang -server -out=go_server/proto/server.gen.go
```