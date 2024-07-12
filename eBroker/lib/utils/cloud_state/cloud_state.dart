import 'package:flutter/material.dart';

// Abstract class for managing cloud data state
abstract class CloudState<T extends StatefulWidget> extends State<T> {
  // Static map to store cloud data shared across instances
  static Map<dynamic, dynamic> cloudData = {};

  // Method to get all cloud data
  Map<dynamic, dynamic> getCloudDataAll() {
    return cloudData;
  }

  // Global single listener for item addition
  static void Function(String key, dynamic value)? onItemAdd;
  static List<void Function(String key, dynamic value)>? _listeners = [];

  // Method to add a listener for a specific key
  listenOn(String key, Function(dynamic value) callBack) {
    _listeners?.add((String addedKey, dynamic addedValue) {
      if (key == addedKey) {
        callBack.call(addedValue);
      } else if (key == "*") {
        callBack.call({addedKey: addedValue});
      }
    });
  }

  // Method to notify all listeners about changes
  void notify(String key, dynamic value) {
    _listeners?.forEach((element) {
      element.call(key, value);
    });
  }

  // Method to get cloud data for a specific key
  getCloudData(String key) {
    return cloudData[key];
  }

  // Method to add cloud data and notify listeners
  void addCloudData(String key, dynamic value) {
    cloudData.addAll(Map<dynamic, dynamic>.from({key: value}));
    notify(key, value);
  }

  void insertCloudData(String key, dynamic value) {
    if (!cloudData.containsKey(key)) {
      cloudData[key] = {};
    }
    if (cloudData[key] is Map) {
      cloudData[key].addAll(Map<dynamic, dynamic>.from({key: value}));
    }

    notify(key, value);
  }

  // Method to add screen-specific data and notify listeners
  void addScreenValue(String key, dynamic value) {
    cloudData.addAll({key: value});
    notify(key, value);
  }

  // Method to set cloud data for a specific key and notify listeners
  void setCloudData(String key, dynamic value) {
    cloudData[key] = value;
    notify(key, value);
  }

  // Method to append a value to a list in cloud data and notify listeners
  void appendToList<T>(String key, T value, {bool? disableClone}) {
    if (!cloudData.containsKey(key)) {
      cloudData[key] = [value];
    }
    if (cloudData[key] is List<T>) {
      if (disableClone == true) {
        if (!(cloudData[key] as List<T>).contains(value)) {
          (cloudData[key] as List<T>).add(value);
          notify(key, value);
        }
      } else {
        (cloudData[key] as List<T>).add(value);
        notify(key, value);
      }
    }
  }

  void appendToListWhere<T>({
    required String listKey,
    required String whereKey,
    required T equals,
    required Map<String, dynamic> add,
    bool? disableClone,
  }) {
    cloudData.putIfAbsent(listKey, () => [add]);

    if (cloudData[listKey] is List<Map<String, dynamic>>) {
      var list = cloudData[listKey] as List<Map<String, dynamic>>;

      if (disableClone != true ||
          !list.any((item) => item[whereKey] == equals)) {
        int indexWhere =
            list.indexWhere((element) => element[whereKey] == equals);
        if (indexWhere >= 0) {
          list[indexWhere] = add;
        } else {
          list.add(add);
          notify(listKey, add);
        }
      }
    }
  }

  void removeFromListWhere<T>({
    required String listKey,
    required String whereKey,
    required T equals,
  }) {
    print("list key ${whereKey} ex $equals");

    if (cloudData.containsKey(listKey) &&
        cloudData[listKey] is List<Map<String, dynamic>>) {
      var list = cloudData[listKey] as List<Map<String, dynamic>>;
      int indexWhere =
          list.indexWhere((element) => element[whereKey] == equals);
      print("list key ${list} $indexWhere");

      if (indexWhere >= 0) {
        var removedItem = list.removeAt(indexWhere);
        notify(listKey, removedItem);
      }
    }
  }

  CloudState<T> toGroup(String groupName, dynamic key, dynamic value) {
    // Check if the group exists in cloudData
    if (!cloudData.containsKey(groupName)) {
      cloudData[groupName] = {}; // Initialize as an empty map if not present
    }

    // Now you can safely access and update the group's key-value pair
    cloudData[groupName][key] = value;
    return this;
  }

  void removeFromGroup(String groupName, dynamic key) {
    if (cloudData.containsKey(groupName)) {
      if (cloudData[groupName].containsKey(key)) {
        cloudData[groupName].remove(key);
      }
    }
  }

  void clearGroup(String name) {
    if (cloudData.containsKey(name)) {
      cloudData.remove(name);
    }
  }

  dynamic fromGroup(String groupName, dynamic key) {
    return cloudData[groupName][key];
  }

  Map? group(String groupName) {
    return cloudData[groupName] as Map?;
  }

  // Method to add screen-specific data in the cloud data
  void screenData(String key, dynamic value) {
    if (cloudData.containsKey(runtimeType)) {
      (cloudData[runtimeType] as Map).addAll({key: value});
    } else {
      cloudData[runtimeType] = {};
      (cloudData[runtimeType] as Map).addAll({key: value});
    }
  }

  // Method to get screen-specific data from the cloud data
  dynamic getScreenData(State screen, String key) {
    return cloudData[screen][key] ?? {};
  }

  // Override build method, as it's an abstract class
  @override
  Widget build(BuildContext context);
}
