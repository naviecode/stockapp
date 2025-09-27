import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

void showErrorToast(BuildContext context, String message) {
  Flushbar(
    message: message,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    backgroundColor: Colors.redAccent,
    duration: const Duration(seconds: 3),
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.FLOATING,
    icon: const Icon(Icons.error, color: Colors.white),
  ).show(context);
}

void showSuccessToast(BuildContext context, String message) {
  Flushbar(
    message: message,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    backgroundColor: Colors.green,
    duration: const Duration(seconds: 3),
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.FLOATING,
    icon: const Icon(Icons.check_circle, color: Colors.white),
  ).show(context);
}
