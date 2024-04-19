import 'package:flutter/material.dart';
import 'package:flutter_app/generated/sdk.dart';
import 'package:provider/provider.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatefulWidget {
  const SampleItemDetailsView({super.key, required this.summary});

  final ItemSummary summary;

  @override
  State<SampleItemDetailsView> createState() => _SampleItemDetailsViewState();
}

class _SampleItemDetailsViewState extends State<SampleItemDetailsView> {
  late Future<({Item item})> itemFuture;
  int itemCount = 0;

  @override
  void initState() {
    super.initState();
    // wait for the item to be fetched and display its details
    // see https://docs.flutter.dev/cookbook/networking/fetch-data
    //
    // be sure to import the 'provider' package to get access to the extension
    // that lets you "read" the SDK instance created in main.dart
    //
    // note that generally you'd use a controller that holds some state
    // for you rather than call the service directly
    final ExampleService service = context.read<ExampleService>();
    itemFuture = service.getItem(widget.summary.id).then((value) {
      setState(() {
        itemCount = value.item.count;
      });
      return value;
    });
  }

  void _onAddOne() {
    // optimistic update
    setState(() {
      itemCount += 1;
    });
    context.read<ExampleService>().putOne(widget.summary.id).onError((error, stackTrace) {
      // Generally you'd inform the user that something went wrong and, depending
      // on the context, report something went wrong. For now, we're just going
      // to undo our optimistic update.
      debugPrint(_parseError(error));
      setState(() {
        itemCount -= 1;
      });
    });
  }

  void _onTakeOne() {
    // optimistic update
    setState(() {
      itemCount -= 1;
    });
    context.read<ExampleService>().takeOne(widget.summary.id).onError((error, stackTrace) {
      // Generally you'd inform the user that something went wrong and, depending
      // on the context, report something went wrong. For now, we're just going
      // to undo our optimistic update.
      debugPrint(_parseError(error));
      setState(() {
        itemCount += 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.summary.name} details"),
      ),
      body: FutureBuilder<({Item item})>(
        future: itemFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            String msg = "Error fetching  details for ${widget.summary.id}";
            if (snapshot.error is WebrpcError) {
              msg += ": ${(snapshot.error as WebrpcError).message}";
            } else if (snapshot.error is WebrpcException) {
              msg = ": ${(snapshot.error as WebrpcException).message}";
            }
            return Center(
              child: Text(msg),
            );
          }
          final Item item = snapshot.data!.item;
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text("Tier: ${item.tier}"),
                    Text("Count: $itemCount"),
                    Text("Created: ${item.createdAt.toString()}"),
                    Text("Last update: ${item.lastUpdate?.toString() ?? "never"}"),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton.small(
                          onPressed: _onTakeOne,
                          child: const Icon(Icons.remove),
                        ),
                        FloatingActionButton.small(
                          onPressed: _onAddOne,
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }
}

String _parseError(Object? err) {
  if (err is WebrpcError) {
    return err.message;
  } else if (err is WebrpcException) {
    return err.message;
  } else {
    return err.toString();
  }
}
