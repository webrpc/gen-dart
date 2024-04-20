import 'package:flutter/material.dart';
import 'package:flutter_app/generated/sdk.dart';

void showErrorNotification(Object? error, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(_parseError(error)),
    showCloseIcon: true,
    duration: const Duration(seconds: 1),
  ));
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
