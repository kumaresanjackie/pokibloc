on:
  pull_request:
    branches:
      - main
      - master
  push:
    branches:
      - main
      - master
      - develop
name: "Build & Release"
jobs:
  build:
    name: Build & Release
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '12'
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          architecture: x64

      - run: flutter build apk --release --split-per-abi
      - run: |
          flutter build ios --no-codesign
          cd build/ios/iphoneos
          mkdir Payload
          cd Payload
          ln -s ../Runner.app
          cd ..
          zip -r app.ipa Payload
      - name: Push to Releases
        uses: ncipollo/release-action@v1
        with:
          artifacts: "build/app/outputs/apk/release/*,build/ios/iphoneos/app.ipa"
          tag: v1.0.${{ github.run_number }}
          token: ${{ secrets.TOKEN }}






