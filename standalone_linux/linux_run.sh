#!/usr/bin/env bash
echo "includePaths:
    - overwrites
    - SCClassLibrary
    - plugins
    - Extensions
excludePaths:
    - /usr/share/SuperCollider/Extensions
    - /usr/share/SuperCollider/SCClassLibrary
    - /Library/Application Support/SuperCollider/Extensions
    - /Applications/SuperCollider.app/Contents/Resources/SCClassLibrary
postInlineWarnings: false" > langconf.yaml;
./sclang -llangconf.yaml Windows.scd

