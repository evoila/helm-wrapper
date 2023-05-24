#!/bin/sh
cd /app/helm-wrapper
chmod +x kusim-helm-wrapper-0.0.1-SNAPSHOT
touch config.yaml
./kusim-helm-wrapper-0.0.1-SNAPSHOT
