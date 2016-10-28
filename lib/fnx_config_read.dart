/// Methods to access your configuration.
///
library fnx_config.read;

import 'dart:convert';
import 'dart:html';
import 'dart:js';

Map _configCache;

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
  if (_configCache != null) return;

  final jsConfig = context['fnx_config'];
  if (jsConfig == null) {
    throw new Exception("Global JS variable 'fnx_config' is null, "
        + "please check configuration of 'fnx_config' transformer in pubspec.yaml"
        + "or add <script type=\"pub/fnx_config\"></script> to your HTML");
  }

  if (jsConfig is String) {
    final json = window.atob(jsConfig);
    _configCache = JSON.decode(json);
  } else {
    throw new Exception("Content of 'fnx_config' should be String");
  }
}