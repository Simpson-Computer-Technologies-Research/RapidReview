import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Create the storage map
Map storage = {"profile_image_bytes": {}, "profile_image_colors": {}};

class Cache {
  static List getImageColor(bytes) {
    img.Image? bitmap = img.decodeImage(bytes);

    int red = 0, green = 0, blue = 0;
    int size = bitmap!.height * bitmap.width;
    for (int y = 0; y < bitmap.height; y++) {
      for (int x = 0; x < bitmap.width; x++) {
        int c = bitmap.getPixel(x, y);
        red += img.getRed(c);
        green += img.getGreen(c);
        blue += img.getBlue(c);
      }
    }
    red = red ~/ size;
    blue = blue ~/ size;
    green = green ~/ size;

    if (red > blue && red > green) {
      red += red ~/ 2.72;
    } else if (blue > red && blue > green) {
      blue += blue ~/ 2.92;
    } else {
      green += green ~/ 3.12;
    }
    if (red < 65 && green < 65 && blue < 65) {
      return [255 - (red ~/ 0.21), 255 - (green ~/ 0.14), 255 - (blue ~/ 0.18)];
    }
    return [red, green, blue];
  }

  static Color rgbConvert(List values) =>
      Color.fromRGBO(values[0], values[1], values[2], 1);

  static Future<Map> getProfileImageBytes(String url) async {
    if (!storage["profile_image_bytes"].containsKey(url)) {
      // Get the image colors from the secure storage
      if (storage["profile_image_colors"] == {}) {
        storage["profile_image_colors"] = await Storage.get(key: "profile_image_colors");
      }
      // HTTP Request to get the image bytes
      http.Response r = await http.get(Uri.parse(url));
      storage["profile_image_bytes"][url] = Image.memory(r.bodyBytes).image;
      // Update the cache storage with the image
      if (!storage["profile_image_colors"].containsKey(url)) {
        storage["profile_image_colors"][url] = getImageColor(r.bodyBytes);
        Storage.update(key: "profile_image_colors", data: storage["profile_image_colors"]);
      }
    }
    return storage;
  }

  static ImageProvider<Object> getImageFromMemory(String url) {
    if (storage["profile_image_bytes"].containsKey(url)) {
      return storage["profile_image_bytes"][url];
    }
    return NetworkImage(url);
  }
}

class Storage {
  static Future<Map> get({required String key}) async {
    var _data = await const FlutterSecureStorage().read(key: key);
    if (_data == null) {
      update(key: key, data: {});
      return {};
    }
    return json.decode(_data);
  }

  static Future<void> update({required String key, required Map data}) async =>
      await const FlutterSecureStorage().write(key: key, value: json.encode(data));
}
