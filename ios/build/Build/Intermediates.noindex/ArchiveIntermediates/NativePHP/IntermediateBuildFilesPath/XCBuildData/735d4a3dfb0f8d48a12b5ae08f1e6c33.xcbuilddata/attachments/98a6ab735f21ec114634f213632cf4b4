#!/bin/zsh
source ~/.zshrc

echo "Installing Prout app..."
mkdir -p $PROJECT_DIR/NativePHP/app
rsync -aL --delete --checksum "$PROJECT_DIR/../" "$PROJECT_DIR/NativePHP/app/"

cd $PROJECT_DIR/NativePHP/app
echo "Installing node dependencies..."
npm ci --audit false

echo "Running node build..."
echo "Removing unnecessary files & folders..."
rm -rf ios
rm -rf node_modules
rm -rf vendor/bin
rm -rf vendor/nativephp/ios/resources
rm -rf tests
rm -rf storage/logs
rm -rf storage/framework

rm database/database.sqlite
rm public/hot

rm *.js
rm *.md
rm *.lock
rm *.xml
rm .env.example

php artisan native:clean-env
rm artisan

