# Feed

![Flutter](https://img.shields.io/badge/Flutter-2.0+-blue.svg)
![Pub Version](https://img.shields.io/pub/v/feed)
![License](https://img.shields.io/badge/License-BSD-green.svg)

**Feed** is a Flutter package that enables developers to create dynamic feeds of content that lazy load when they reach the bottom. This package simplifies the process of managing and displaying large sets of data in a Flutter app. With Feed, you can efficiently load and display data as the user scrolls through a feed, providing a smooth and responsive user experience.

**Installation**: Add `feed` to your `pubspec.yaml` file under `dependencies`:

```yaml
dependencies:
   feed: ^1.0.0  # Replace with the latest version
```

## FeedController
The FeedController is a fundamental component of the Feed package, responsible for managing your feed's data and controlling its behavior. It provides methods and properties to interact with the feed, including refreshing the feed, loading more items, and managing the feed's content.

### Creating a FeedController
To get started, you'll need to create an instance of FeedController and configure it with the necessary parameters, such as the data fetching function and feed settings.
```dart
import 'package:flutter/material.dart';
import 'package:feed/feed.dart';

class MyFeed extends StatefulWidget {
  @override
  _MyFeedState createState() => _MyFeedState();
}

class _MyFeedState extends State<MyFeed> {
  // Create a FeedController for your data type (e.g., String)
  final FeedController<String> _feedController = FeedController<String>(
    fetch: (offset, limit) async {
      // Implement your data fetching logic here
      // Return a List of data to be added to the feed
      return [];
    },
    limit: 20, // Set the limit for each query
  );

  @override
  void initState() {
    super.initState();
    // Initialize the feed controller
    _feedController.init();
  }

  @override
  void dispose() {
    // Dispose of the feed controller when it's no longer needed
    _feedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed Example'),
      ),
      body: FeedListView<String>(
        controller: _feedController,
        builder: (context, item) {
          // Build your feed item widget here
          return ListTile(
            title: Text(item),
          );
        },
      ),
    );
  }
}
```
### FeedController Parameters

The `FeedController` is a powerful tool for managing feeds in your Flutter app. It provides various parameters that allow you to customize and control the behavior of your feed.

#### `fetch` (Required)

- **Type:** `List<Future<List<T>> Function(int offset, int limit)>`

   The `fetch` parameter is a required parameter that defines the data fetching function for your feed. It should be a list of functions that return a list of data when invoked. These functions are responsible for querying and fetching data based on the `offset` and `limit` provided.

#### `limit`

- **Type:** `int`
- **Default:** `20`

   The `limit` parameter specifies the maximum number of items to fetch and display per query. Adjust this value to control how many items are loaded at a time. The default limit is set to 20.

#### `startsWith`

- **Type:** `List<T>?`
- **Default:** `null`

   The `startsWith` parameter allows you to provide an initial list of items to populate the feed. This is useful when you want to start the feed with some predefined content.

#### `sort`

- **Type:** `int Function(T a, T b)?`
- **Default:** `null`

   The `sort` parameter is a function that defines how the data should be sorted once it's fetched. You can provide a custom sorting function to order the feed items as needed.

#### `filter`

- **Type:** `FeedFilter<T>?`
- **Default:** `null`

   The `filter` parameter allows you to apply a filter to incoming elements based on a provided filter function. If specified, the filter function decides whether to include or exclude an element in the feed.

#### `initialized`

- **Type:** `bool`
- **Default:** `false`

   The `initialized` parameter determines whether the feed controller is initialized. It is set to `true` after calling `init()` on the controller.

#### `scrollController`

- **Type:** `ScrollController?`
- **Default:** `null`

   The `scrollController` parameter allows you to attach a custom `ScrollController` to your feed. You can use this controller to interact with the scroll behavior of the feed.

#### `startsWithLoading`

- **Type:** `bool`
- **Default:** `true`

   The `startsWithLoading` parameter specifies whether the feed should start with a loading state. When set to `true`, the feed will display a loading indicator while the initial data is being fetched.

#### `loadingItemBuilder`

- **Type:** `Widget Function(BuildContext)?`
- **Default:** `null`

   The `loadingItemBuilder` parameter allows you to customize the loading indicator widget displayed in the feed. Provide a function that returns the loading widget.

#### `pagingEnabled`

- **Type:** `bool`
- **Default:** `true`

   The `pagingEnabled` parameter determines whether the feed supports paging. When set to `true`, the feed will automatically load more data as the user scrolls to the bottom. Disable this to implement custom paging behavior.

#### `refreshOnAppResumed`

- **Type:** `bool`
- **Default:** `false`

   The `refreshOnAppResumed` parameter controls whether the feed should refresh its content when the app is resumed after being in the background. Set it to `true` to enable this behavior.

#### `initialLoad`

- **Type:** `bool`
- **Default:** `true`

   The `initialLoad` parameter specifies whether the feed should load data immediately after initialization. When set to `true`, the feed will initiate the initial data load.

#### `refreshOnPullDown`

- **Type:** `bool`
- **Default:** `true`

   The `refreshOnPullDown` parameter determines whether the feed should refresh its content when the user pulls down on the feed view. Set it to `true` to enable pull-to-refresh functionality.

#### `loadOnRefresh`

- **Type:** `bool`
- **Default:** `true`

   The `loadOnRefresh` parameter controls whether the feed should automatically load more data when the user performs a refresh action. Set it to `true` to enable loading on refresh.

#### `scrollController`

- **Type:** `ScrollController?`
- **Default:** `null`

   The `scrollController` parameter allows you to attach a custom `ScrollController` to your feed. You can use this controller to interact with the scroll behavior of the feed.

#### `onError`

- **Type:** `void Function(dynamic)?`
- **Default:** `null`

   The `onError` parameter is a callback function that is triggered when an error occurs during data fetching. You can use it to handle and log errors.

These parameters provide fine-grained control over how your feed behaves and how it interacts with your app's user interface.

For more advanced usage and customization, refer to the package documentation and code comments.
