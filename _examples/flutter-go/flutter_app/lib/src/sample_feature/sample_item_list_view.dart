import 'package:flutter/material.dart';
import 'package:flutter_app/generated/sdk.dart';
import 'package:flutter_app/src/sample_feature/error.dart';
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
      showErrorNotification(error, context);
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

  Future<void> _onCreateItem(CreateItemRequest req) async {
    await context.read<ExampleService>().createItem(req).onError((error, stackTrace) {
      showErrorNotification(error, context);
    }).whenComplete(_updateItems);
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
                          _dialogBuilder(context, _onCreateItem);
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

Future<void> _dialogBuilder(BuildContext context, Future<void> Function(CreateItemRequest req) onSubmit) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return _CreateItemForm(onSubmit: onSubmit);
    },
  );
}

class _CreateItemForm extends StatefulWidget {
  const _CreateItemForm({required this.onSubmit});

  final Future<void> Function(CreateItemRequest req) onSubmit;

  @override
  State<_CreateItemForm> createState() => _CreateItemFormState();
}

class _CreateItemFormState extends State<_CreateItemForm> {
  String? name;
  ItemTier tier = ItemTier.REGULAR;

  List<ItemTier> options = ItemTier.values;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add an item'),
      content: SizedBox(
        width: 200,
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a name',
                ),
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: DropdownButton<ItemTier>(
                value: tier,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (ItemTier? value) {
                  setState(() {
                    tier = value!;
                  });
                },
                items: options.map<DropdownMenuItem<ItemTier>>((ItemTier value) {
                  return DropdownMenuItem<ItemTier>(
                    value: value,
                    child: Text(value.name),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Submit'),
          onPressed: () {
            // generally should inform the user they have an invalid form
            if (name == null) return;
            widget.onSubmit(CreateItemRequest(name: name!, tier: tier)).whenComplete(() => Navigator.of(context).pop());
          },
        ),
      ],
    );
  }
}
