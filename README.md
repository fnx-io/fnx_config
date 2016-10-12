# fnx_config - configuration management

This is a transformer which helps you manage different configurations for different builds of your web app.


Usually you need different configuration for different environments:

    String apiRoot = "http://localhost:8080/api/v1
    // Use in production!!!!!
    // String apiRoot = "http://this-is-very-important.qwerty/api/v1/"
    
... and that's just terrible. Let's try something else.    
        
## Usage

Add transformer to your pubspec.yaml:

    dependencies:
      fnx_config: ^1.0.0
    
    transformers:
    - fnx_config

Then create configuration profiles (YAML files). Usually you will need two of them.
 
- `lib/conf/config_debug.yaml` - for `pub serve`
- `lib/conf/config_release.yaml` - for `pub build`

Content of those files is completely up to you, it's probably going to be something like this:

    ourSecretApiKey: qwertyuiop
    ourSecretApiUrl: http://this-is-very-secret.qwerty/api/v1/

Then add `<script type="pub/fnx_config"></script>` into the `<head>`
of your HTML files and run `pub serve`.

## Result

Transformer searches for HTML files with this instruction, and replaces it with encoded content of
your YAML file:

    var fnx_config = "eyJjb25maWciOnsiYWhvai  ... tMjlUMTg6NDE6MjAuMTkwIn19";
    
The reason why we encode the configuration, is that we don't want to
tempt the user with too much knowledge. We don't need any bored teenager
to play with our API endpoints and API keys.

**Please don't mistake this feature for any kind of security**,
it's just simple BASE64 and the configuration will be accessible to any skilled user. 
But a little bit of obfuscation cannot do any harm. 

See [example](http://demo.fnx.io/fnx_config-examples).

## Reading

Import

    import 'package:fnx_config/fnx_config_read.dart';

and access your configuration via global function:

    String apiKey = fnxConfig()["ourSecretApiKey"];
    
**fnx_config** also adds few metadata you might find useful:

    fnxConfigMeta()["mode"]; // pub build mode (--mode=qwerty)
    fnxConfigMeta()["timestamp"]; // timestamp of build    
        
## Multiple configuration profiles
        
Simply add more configuration files:

    lib/conf/config_qwerty.yaml
    lib/conf/config_jenkins.yaml

and use them with pub:
     
    pub build --mode=qwerty
    pub serve --mode=jenkins

# Examples            
            
## Polymer    

With Polymer, place **fnx_config** transformer after web_components

	- web_components:
    		entry_points: web/index.html
	- reflectable:
    		entry_points: web/index.dart
	- fnx_config
	
## Angular2

Position of `fnx_config` doesn't seem to matter with Angular2. We keep it a the end of the list of
transformers.

## Firebase example

Typical usage with [firebase](https://pub.dartlang.org/packages/firebase3) looks like this:

config_debug.yaml

    firebase:
      apiKey: "AIzaSyDq6qYBJHOMmdsdsEsKFiotLxKmjqA"
      authDomain: "my-app-1af5.firebaseapp.com"
      databaseURL: "https://my-app-1af5.firebaseio.com"
      storageBucket: "my-app-1af5.appspot.com"
      
main.dart
      
    import 'package:firebase3/firebase.dart' as f;
    import 'package:fnx_config/fnx_config_read.dart';
      
    ...
      
    Map cfg = fnxConfig();    
    f.App app = f.initializeApp(
      apiKey: cfg["firebase"]["apiKey"],
      authDomain: cfg["firebase"]["authDomain"],
      databaseURL: cfg["firebase"]["databaseURL"],
      storageBucket: cfg["firebase"]["storageBucket"]
    );      

	
