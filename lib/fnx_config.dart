/// Transformer which includes
/// build mode dependent configuration into your HTML file.
///
library fnx_config.transform;

import 'package:barback/barback.dart';
import 'dart:async' show Future;
import 'package:html5lib/parser.dart' show parse;
import 'package:yaml/yaml.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

String _toBase64(String string) {
  Base64Encoder e = new Base64Encoder();
  return e.convert(UTF8.encode(string));
}

/// Finds script tags with type="pub/fnx_config", and replaces their inner content
/// with encoded configuration.
///
/// There is no reason to have more then one of such script tags on a page.
class FnxConfig extends Transformer {

  String mode = null;

  Pattern yamlConfigName = new RegExp(r"^lib/conf/config_[^/]*.yaml$");

  FnxConfig.asPlugin(BarbackSettings _settings) {
    mode = _settings.mode.name;
  }

  String get allowedExtensions => ".html .yaml";

  Future apply(Transform transform) async {

    var id = transform.primaryInput.id;

    if (id.path.contains(yamlConfigName)) {
      _cleanYamlConfigFile(transform);

    } else if (id.path.endsWith(".html")) {
      return _embedConfiguration(transform);

    } else {
      // nothing
    }
  }

  Future _cleanYamlConfigFile(Transform transform) {
    transform.addOutput(new Asset.fromString(transform.primaryInput.id, "# content deleted by fnx_config transformer"));
    return null;
  }

  Future _embedConfiguration(Transform transform) async {

    AssetId configId = new AssetId(transform.primaryInput.id.package, "lib/conf/config_${mode}.yaml");

    String yamlSource = await transform.readInputAsString(configId);
    YamlNode yamlCfg = loadYaml(yamlSource);

    Map finalConfig = {
      "config" : yamlCfg,
      "meta": {
        "mode" : mode,
        "timestamp": new DateTime.now().toIso8601String()
      }
    };

    String jsonEncoded = JSON.encode(finalConfig);

    return transform.primaryInput.readAsString().then((content) {

      var document = parse(content);

      // attribute selectors don't work yet, do it manually
      var scripts = document.querySelectorAll('script')
      .where((scriptTag) {
        return scriptTag.attributes['type'] == "pub/fnx_config";

      }).forEach((configScriptTag) {
        configScriptTag.text = " var fnx_config = \"${_toBase64(jsonEncoded)}\";";
        configScriptTag.attributes.remove("type");
      });

      transform.addOutput(new Asset.fromString(transform.primaryInput.id, document.outerHtml));
    }
    );
  }

  isPrimary(AssetId id) {
    return id.path.endsWith(".html") || id.path.contains(yamlConfigName);
  }

}