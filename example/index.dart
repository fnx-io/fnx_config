import 'dart:html';
import 'package:fnx_config/fnx_config_read.dart';

void main() {
  querySelector("#config").text = fnxConfig().toString();
  querySelector("#meta").text = fnxConfigMeta().toString();

  print("Config: ${fnxConfig()}");
  print("Meta: ${fnxConfigMeta()}");
}