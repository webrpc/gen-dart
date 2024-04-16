# gen-dart

webrpc-gen Dart templates
===============================

This repo contains the templates used by the `webrpc-gen` cli to code-generate
webrpc Dart server and client code.

This generator, from a webrpc schema/design file will code-generate:

1. Client -- an isomorphic/universal Dart client to speak to a webrpc server using the
provided schema. This client is compatible with any webrpc server language (ie. Go, nodejs, etc.).

2. Server -- a Dart server handler. See examples.

## Usage

```
webrpc-gen -schema=example.ridl -target=dart -server -client -out=./example.gen.dart
```

or 

```
webrpc-gen -schema=example.ridl -target=github.com/webrpc/gen-dart@v0.17.2 -server -client -out=./example.gen.dart
```

or

```
webrpc-gen -schema=example.ridl -target=./local-templates-on-disk -server -client -out=./example.gen.dart
```

As you can see, the `-target` supports default `dart`, any git URI, or a local folder

### Set custom template variables
Change any of the following values by passing `-option="Value"` CLI flag to `webrpc-gen`.

| webrpc-gen -option   | Description                | Default value              |
|----------------------|----------------------------|----------------------------|
| `-client`            | generate client code       | unset (`false`)            |
| `-server`            | generate server code       | unset (`false`)            |

### Avoid using Records
Because Dart [Records do not retain runtime information about their structure](https://github.com/dart-lang/language/issues/2826), it's impossible
to reliably convert them to and from JSON. For this reason, we strongly advise against
using Records in schema objects that have an `any` type (which maps to `dynamic` in Dart). In fact,
you probably should not ever use the `any` type in your schema because it has ambigious
structure which makes its structure meaningless on the other end of the wire. If you need a truly
unstructured object, consider defining an internal convention and declaring it as a string in the schema.

## CONTRIBUTE

### Setup
Install Dart or Flutter. Ensure your version matches the `sdk` version specified in [tests/pubspec.yaml](tests/pubspec.yaml).

Fork this repo.

Run the test scripts to ensure everything is set up correctly.
```bash
cd tests
./scripts/download.sh v0.17.2 .tmp/
./scripts/test.sh
```

Generated code will be written to [tests/lib/client.dart](tests/lib/client.dart)

### Make changes
Refer to the [webrpc generator README](https://github.com/webrpc/webrpc/tree/master/gen) for help on syntax.
In brief, start in [main.go.tmpl] and traverse the template tree by going to the template file
named by `{{template "templateName" <args>}}`, e.g. "templateName.go.tmpl". 

### (Update and) Run tests
Following the typical structure for a Dart package, tests are located in the aptly named
[tests/test/](tests/test/).

### Working with a local version of webrpc?
If you are working with a local version of the base `webrpc` repo, build the generator and test server scripts
there

```bash
cd path/to/webrpc
make build build-test
```

and pass the `webrpc/bin` directory to [tests/scripts/test.sh](tests/scripts/test.sh)

```bash
cd tests
./scripts/test.sh -r path/to/webrpc/bin
```

## LICENSE

[MIT LICENSE](./LICENSE)