import 'package:flutter/material.dart';

class ResultProvider extends ChangeNotifier {
  String withmask = "with_mask";
  String withoutmask = "without_mask";

  bool ismask = false;
  change(var result) {
    String y = result![0]["label"].toString().substring(2);
    ismask = (y == withmask);
    if (result.length > 1) {
      String t = result![1]["label"].toString().substring(2);
      if (t == withmask) {
        if (result[1]["confidence"] > 0.4) {
          ismask = (t == withmask);
        }
      }
    }

    notifyListeners();
  }
}
