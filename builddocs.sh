# remove old built documentation
rm -rf .build
# build the web version for github
xcodebuild docbuild -scheme PonyExpress -destination generic/platform=iOS OTHER_DOCC_FLAGS="--transform-for-static-hosting --hosting-base-path PonyExpress --output-path docs"
# build the Xcode doccarchive version
xcodebuild docbuild -scheme PonyExpress -destination generic/platform=iOS OTHER_DOCC_FLAGS="--output-path PonyExpress.doccarchive"
# move that Xcode version into a hidden folder and open it to install it 
mkdir .build
mv PonyExpress.doccarchive .build/PonyExpress.doccarchive
open .build/PonyExpress.doccarchive
# format all json files in the docs folder so that the built files are deterministic
find docs -name *.json -exec bash -c 'jq -M -c --sort-keys . < "{}" > "{}.temp"; mv "{}.temp" "{}"' \;
# add an empty Package.swift into docs/ so that it doesn't appear in Xcode
printf "// swift-tools-version: 5.7\n// The swift-tools-version declares the minimum version of Swift required to build this package.\n\nimport PackageDescription\n\nlet package = Package()\n" > docs/Package.swift
