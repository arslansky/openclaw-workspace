#!/bin/bash
# Image Organizer Script
# Auto-categorizes images by type and creates metadata

SOURCE_DIR="/root/.openclaw/media"
TARGET_DIR="/root/.openclaw/workspace/images"

# Create directories
mkdir -p "$TARGET_DIR/by-date"
mkdir -p "$TARGET_DIR/by-type/{reporters,anime,gundam,others}"
mkdir -p "$TARGET_DIR/favorites"

# Function to detect image type
detect_type() {
    local filename="$1"
    local prompt="$2"
    
    if echo "$filename $prompt" | grep -qi "reporter\|記者\|news\|anchor"; then
        echo "reporters"
    elif echo "$filename $prompt" | grep -qi "gundam\|高達\|mecha\|robot"; then
        echo "gundam"
    elif echo "$filename $prompt" | grep -qi "anime\|girl\|character\|manga"; then
        echo "anime"
    else
        echo "others"
    fi
}

# Process tool-generated images
echo "Processing tool-generated images..."
for file in "$SOURCE_DIR"/tool-image-generation/*.png "$SOURCE_DIR"/tool-image-generation/*.jpg; do
    [ -f "$file" ] || continue
    
    filename=$(basename "$file")
    date_str=$(date -r "$file" +%Y-%m-%d 2>/dev/null || echo "unknown")
    
    # Copy to by-date
    mkdir -p "$TARGET_DIR/by-date/$date_str"
    cp "$file" "$TARGET_DIR/by-date/$date_str/"
    
    # Detect type and copy to by-type
    img_type=$(detect_type "$filename" "")
    cp "$file" "$TARGET_DIR/by-type/$img_type/"
    
    echo "  ✓ $filename -> $date_str / $img_type"
done

# Process inbound images (optional, for Telegram uploads)
echo "Processing inbound images..."
for file in "$SOURCE_DIR"/inbound/*.png "$SOURCE_DIR"/inbound/*.jpg; do
    [ -f "$file" ] || continue
    
    filename=$(basename "$file")
    date_str=$(date -r "$file" +%Y-%m-%d 2>/dev/null || echo "unknown")
    
    # Only organize if it looks like generated content
    if echo "$filename" | grep -qE "(aethercode|generated|image-|tool-)"; then
        mkdir -p "$TARGET_DIR/by-date/$date_str"
        cp "$file" "$TARGET_DIR/by-date/$date_str/"
        
        img_type=$(detect_type "$filename" "")
        cp "$file" "$TARGET_DIR/by-type/$img_type/"
        
        echo "  ✓ $filename -> $date_str / $img_type"
    fi
done

echo "Done! Images organized in:"
echo "  - $TARGET_DIR/by-date/"
echo "  - $TARGET_DIR/by-type/"
