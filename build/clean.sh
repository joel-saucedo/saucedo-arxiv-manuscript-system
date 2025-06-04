#!/bin/bash
# clean.sh - Comprehensive cleaning script for Saucedo arXiv Manuscript System

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

show_help() {
    echo "Clean Script for Saucedo arXiv Manuscript System"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  --build        Clean only build directory"
    echo "  --output       Clean only output directory"
    echo "  --all          Clean everything (default)"
    echo "  --latex        Clean LaTeX auxiliary files"
    echo "  --help         Show this help message"
    echo ""
    echo "The script removes:"
    echo "  - LaTeX auxiliary files (.aux, .log, .bbl, .blg, etc.)"
    echo "  - Build directory contents"
    echo "  - Output directory contents"
    echo "  - Temporary files"
}

# Clean LaTeX auxiliary files
clean_latex_aux() {
    log_info "Cleaning LaTeX auxiliary files..."
    
    cd "$PROJECT_DIR"
    
    # Common LaTeX auxiliary file extensions
    local extensions=(
        "*.aux" "*.log" "*.bbl" "*.blg" "*.toc" "*.lof" "*.lot"
        "*.out" "*.fdb_latexmk" "*.fls" "*.synctex.gz" "*.nav"
        "*.snm" "*.vrb" "*.bcf" "*.run.xml" "*.figlist" "*.makefile"
        "*.glo" "*.idx" "*.ilg" "*.ind" "*.ist" "*.acn" "*.acr"
        "*.alg" "*.glg" "*.gls" "*.xdy" "*.thm" "*.loa" "*.lol"
    )
    
    local count=0
    for ext in "${extensions[@]}"; do
        if find . -name "$ext" -type f | grep -q .; then
            find . -name "$ext" -type f -delete
            count=$((count + $(find . -name "$ext" -type f | wc -l)))
        fi
    done
    
    # Clean specific directories
    if [ -d "build" ]; then
        find build/ -name "*.aux" -o -name "*.log" -o -name "*.bbl" -o -name "*.blg" | xargs -r rm -f
    fi
    
    log_success "Cleaned $count LaTeX auxiliary files"
}

# Clean build directory
clean_build() {
    log_info "Cleaning build directory..."
    
    if [ -d "$PROJECT_DIR/build" ]; then
        find "$PROJECT_DIR/build" -type f ! -name "Makefile" ! -name "build.sh" ! -name "clean.sh" ! -name ".gitkeep" -delete 2>/dev/null || true
        log_success "Build directory cleaned"
    else
        log_warning "Build directory not found"
    fi
}

# Clean output directory
clean_output() {
    log_info "Cleaning output directory..."
    
    if [ -d "$PROJECT_DIR/output" ]; then
        rm -rf "$PROJECT_DIR/output"/*
        log_success "Output directory cleaned"
    else
        log_warning "Output directory not found"
    fi
}

# Clean temporary files
clean_temp() {
    log_info "Cleaning temporary files..."
    
    cd "$PROJECT_DIR"
    
    # Remove common temporary files
    find . -name "*~" -type f -delete 2>/dev/null || true
    find . -name "*.tmp" -type f -delete 2>/dev/null || true
    find . -name "*.bak" -type f -delete 2>/dev/null || true
    find . -name ".DS_Store" -type f -delete 2>/dev/null || true
    find . -name "Thumbs.db" -type f -delete 2>/dev/null || true
    
    log_success "Temporary files cleaned"
}

# Clean everything
clean_all() {
    log_info "Performing comprehensive cleanup..."
    clean_latex_aux
    clean_build
    clean_output
    clean_temp
    log_success "Complete cleanup finished"
}

# Parse command line arguments
ACTION="all"

while [[ $# -gt 0 ]]; do
    case $1 in
        --build)
            ACTION="build"
            ;;
        --output)
            ACTION="output"
            ;;
        --all)
            ACTION="all"
            ;;
        --latex)
            ACTION="latex"
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
    shift
done

# Execute cleaning based on action
case $ACTION in
    build)
        clean_build
        ;;
    output)
        clean_output
        ;;
    latex)
        clean_latex_aux
        ;;
    all)
        clean_all
        ;;
    *)
        echo "Invalid action: $ACTION"
        exit 1
        ;;
esac

log_success "Cleaning completed successfully!"
