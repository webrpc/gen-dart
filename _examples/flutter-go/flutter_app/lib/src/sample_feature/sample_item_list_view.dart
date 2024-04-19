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

  @override
  void initState() {
    super.initState();
    // wait for the items to be fetched and display their summaries
    // see https://docs.flutter.dev/cookbook/networking/fetch-data
    //
    // be sure to import the 'provider' package to get access to the extension
    // that lets you "read" the SDK instance created in main.dart
    //
    // note that generally you'd use a controller that holds some state
    // for you rather than call the service directly
    final ExampleService service = context.read<ExampleService>();
    itemsFuture = service.getItems();
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
                  final item = items[index];

                  return ListTile(
                      title: Text(item.name),
                      leading: const CircleAvatar(
                        // Display the Flutter Logo image asset.
                        foregroundImage: AssetImage('assets/images/flutter_logo.png'),
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
                    FloatingActionButton.extended(
                        onPressed: () {
                          debugPrint("hello");
                        },
                        label: const Icon(Icons.add)),
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
