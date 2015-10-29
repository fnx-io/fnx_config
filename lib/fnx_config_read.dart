/// Methods to access your configuration.
///
library fnx_config.read;

import 'dart:convert';
import 'dart:js';
import 'dart:html';

var _configCache = null;

/// Decodes and reads your configuration from JS global variable 'fnx_config'
///
Map fnxConfig() {
  _readToCache();
  return _configCache["config"];
}

/// Decodes additional meta information: ["mode"] (pub build mode) and ["timestamp"] (of build).
///
Map fnxConfigMeta() {
  _readToCache();
  return _configCache["meta"];
}

void _readToCache() {

  if (_configCache != null) return _configCache;

  var jsConfig = context['fnx_config'];
  if (jsConfig == null) {
    throw "Global JS variable 'fnx_config' is null, "
    +"please check configuration of 'fnx_config' transformer in pubspec.yaml"
    +"or add <script type=\"pub/fnx_config\"></script> to your HTML";
  }

  if (jsConfig is String) {
    String encoded = (jsConfig as String);
    String json = window.atob(encoded);
    _configCache = JSON.decode(json);

  } else {
    throw "Content of 'fnx_config' should be String";
  }

}