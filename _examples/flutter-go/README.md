# flutter-go
An example full-stack app using Flutter as the frontend and a minimal golang server as the backend.

## Structure

| Path                                                | Description |
| --------------------------------------------------- | ---------- |
| [service.ridl](./service.ridl) | Webrpc service schema (types, endpoints, and errors). Shared between client and server. |
| [flutter_app/](./flutter_app/) | Frontend Flutter app (tested on Web only) |
| [flutter_app/lib/main.dart](./flutter_app/lib/main.dart) | Flutter app entry-point |
| [go_server/](./go_server/) | Backend server |

## Try it out
Start the server (after installing Go).
```bash
TBD
```

Start the client (after installing Flutter).
```bash
flutter run -d chrome
```

## Make changes
Try updating the service schema and re-generating the client and server code.

To generate the client
```bash
path/to/webrpc-gen -schema=./service.ridl -target=../../ -client -out=flutter_app/lib/generated/sdk.dart
```

To generate the server
```bash
path/to/webrpc-gen -schema=./service.ridl -target=go -server -out=tbd
```