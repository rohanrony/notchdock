#!/bin/bash

# Define paths
SOURCE_DIR="/Users/rohanroy/.gemini/antigravity-ide/brain/3324633e-4b27-47b8-afd3-648f1ff72daa"
TARGET_DIR="/Users/rohanroy/Coding/notchdock-public/public/assets"

echo "Copying uploaded assets..."

# Copy Stocks expanded widget screenshot
cp "${SOURCE_DIR}/media__1782317288327.png" "${TARGET_DIR}/stocks_view.png"

# Copy Stocks notch status bar screenshot
cp "${SOURCE_DIR}/media__1782317383009.png" "${TARGET_DIR}/notch_stock_bar.png"

# Copy Timer notch status bar screenshot
cp "${SOURCE_DIR}/media__1782317383010.png" "${TARGET_DIR}/notch_timer_bar.png"

echo "Assets copied successfully!"
