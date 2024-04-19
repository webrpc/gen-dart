import 'package:flutter/material.dart';
import 'package:flutter_app/generated/sdk.dart';
import 'package:provider/provider.dart';

import '../settings/settings_view.dart';
import 'sample_item_details_view.dart';

/// Displays a list of SampleItems.
class SampleItemListView extends StatefulWidget {
  const SampleItemListView({
    super.key,
  });

  static const routeName = '/';

  @override
  State<SampleItemListView> createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  late Future<({List<ItemSummary> items})> itemsFuture;
  List<ItemSummary> items = [];

  @override
  void initState() {
    super.initState();
    _updateItems();
  }

  void _onDeleteItem(String itemId) {
    context.read<ExampleService>().deleteItem(itemId).onError((error, stackTrace) {
      // Generally you'd inform the user that something went wrong and, depending
      // on the context, report something went wrong.
      debugPrint(_parseError(error));
    }).whenComplete(_updateItems);
  }

  void _updateItems() {
    itemsFuture = context.read<ExampleService>().getItems().then((value) {
      setState(() {
        items = value.items;
      });
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: Stack(
        children: [
          FutureBuilder(
            future: itemsFuture,
            builder: (context, snapshot) {
              late List<ItemSummary> items;
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                String msg = "Error fetching item inventory";
                if (snapshot.error is WebrpcError) {
                  msg += ": ${(snapshot.error as WebrpcError).message}";
                } else if (snapshot.error is WebrpcException) {
                  msg = ": ${(snapshot.error as WebrpcException).message}";
                }
                return Center(
                  child: Text(msg),
                );
              }
              items = snapshot.data!.items;
              return ListView.builder(
                // Providing a restorationId allows the ListView to restore the
                // scroll position when a user leaves and returns to the app after it
                // has been killed while running in the background.
                restorationId: 'sampleItemListView',
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final ItemSummary item = items[index];

                  return ListTile(
                      title: Text(item.name),
                      leading: const CircleAvatar(
                        // Display the Flutter Logo image asset.
                        foregroundImage: AssetImage('assets/images/flutter_logo.png'),
                      ),
                      trailing: IconButton.filled(
                        onPressed: () => _onDeleteItem(item.id),
                        icon: const Icon(Icons.delete),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SampleItemDetailsView(summary: item),
                          ),
                        );
                      });
                },
              );
            },
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
                    FloatingActionButton.large(
                        onPressed: () {
                          debugPrint("hello");
                        },
                        child: const Icon(Icons.add)),
                  ],
                ),
              )
            ],
          )
        ],
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
