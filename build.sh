#!/bin/bash
# Vercel Build Script for Flutter Web
# Downloads Flutter SDK, adds git safe ownership exceptions, and builds the app.

echo "Setting up Flutter SDK..."
curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.0-stable.tar.xz | tar xJ

echo "Adding git safe directory exceptions..."
git config --global --add safe.directory /vercel/path0/flutter

echo "Fetching Flutter dependencies..."
./flutter/bin/flutter pub get

echo "Building Flutter Web application..."
./flutter/bin/flutter build web

echo "Build process complete!"
