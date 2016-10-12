#!/bin/sh

pub build example &&
cd build/example &&
gcloud --project ma-web compute copy-files * static-ma:/usr/share/nginx/www/demo.fnx.io/fnx_config-examples --zone europe-west1-b &&
cd ../..;
