rm -rf .build
xcodebuild docbuild -scheme PonyExpress -destination generic/platform=iOS OTHER_DOCC_FLAGS="--transform-for-static-hosting --hosting-base-path PonyExpress --output-path docs"
xcodebuild docbuild -scheme PonyExpress -destination generic/platform=iOS OTHER_DOCC_FLAGS="--output-path PonyExpress.doccarchive"
mkdir .build
mv PonyExpress.doccarchive .build/PonyExpress.doccarchive
open .build/PonyExpress.doccarchive

find docs -name *.json -exec bash -c 'jq -M -c --sort-keys . < "{}" > "{}.temp"; mv "{}.temp" "{}"' \;

printf "// swift-tools-version: 5.7\n// The swift-tools-version declares the minimum version of Swift required to build this package.\n\nimport PackageDescription\n\nlet package = Package()\n" > docs/Package.swift
