#!/bin/bash
# figure-compress.py replacement script
# Compresses figures for arXiv size limits

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

# Check if ImageMagick is available
if ! command -v convert &> /dev/null; then
    log_error "ImageMagick 'convert' command not found. Please install ImageMagick."
    exit 1
fi

HIGH_RES_DIR="$PROJECT_DIR/figures/high-res"
COMPRESSED_DIR="$PROJECT_DIR/figures/compressed"

mkdir -p "$COMPRESSED_DIR"

if [ ! -d "$HIGH_RES_DIR" ]; then
    log_error "High-res figures directory not found: $HIGH_RES_DIR"
    exit 1
fi

log_info "Compressing figures for arXiv submission..."

count=0
for file in "$HIGH_RES_DIR"/*.{png,jpg,jpeg,pdf,eps}; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        ext="${filename##*.}"
        name="${filename%.*}"
        
        case $ext in
            png|jpg|jpeg)
                # Compress raster images
                convert "$file" -quality 85 -resize 2048x2048\> "$COMPRESSED_DIR/$filename"
                ;;
            pdf|eps)
                # Copy vector graphics as-is (they're usually smaller)
                cp "$file" "$COMPRESSED_DIR/$filename"
                ;;
        esac
        
        count=$((count + 1))
        log_info "Compressed: $filename"
    fi
done

log_success "Compressed $count figures to $COMPRESSED_DIR"
