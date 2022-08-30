xcodebuild docbuild -scheme PonyExpress -destination generic/platform=iOS OTHER_DOCC_FLAGS="--transform-for-static-hosting --hosting-base-path PonyExpress --output-path docs"
# xcodebuild docbuild -scheme PonyExpress -destination generic/platform=iOS OTHER_DOCC_FLAGS="--output-path .build/PonyExpress.doccarchive"
# open .build/PonyExpress.doccarchive
