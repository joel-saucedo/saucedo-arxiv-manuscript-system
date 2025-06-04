#!/bin/bash
# build.sh - Smart build script for Saucedo arXiv Manuscript System
# Author: Joel Saucedo

set -e  # Exit on any error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_DIR/output"
BUILD_DIR="$PROJECT_DIR/build"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Help function
show_help() {
    echo "Saucedo arXiv Manuscript System - Build Script"
    echo ""
    echo "Usage: $0 [TARGET] [OPTIONS]"
    echo ""
    echo "Targets:"
    echo "  arxiv          Build arXiv optimized version"
    echo "  journal        Build journal submission version"  
    echo "  preprint       Build preprint version with watermark"
    echo "  all            Build all versions"
    echo "  draft          Build draft version with line numbers"
    echo "  quick          Quick single-pass build"
    echo "  package        Create arXiv submission package"
    echo "  clean          Clean build files"
    echo "  watch          Watch for changes and rebuild"
    echo ""
    echo "Options:"
    echo "  --draft        Add draft mode (line numbers, watermark)"
    echo "  --quick        Single-pass compilation (faster)"
    echo "  --verbose      Verbose output"
    echo "  --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 arxiv                # Build arXiv version"
    echo "  $0 journal --draft      # Build journal version with draft features"
    echo "  $0 all --quick          # Quick build all versions"
    echo "  $0 watch arxiv          # Watch and rebuild arXiv version"
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    if ! command -v pdflatex &> /dev/null; then
        log_error "pdflatex not found. Please install LaTeX distribution."
        exit 1
    fi
    
    if ! command -v bibtex &> /dev/null; then
        log_error "bibtex not found. Please install LaTeX distribution."
        exit 1
    fi
    
    log_success "All dependencies found"
}

# Create necessary directories
setup_directories() {
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$BUILD_DIR"
    log_info "Directories set up"
}

# Build function
build_target() {
    local target=$1
    local draft_mode=${2:-false}
    local quick_mode=${3:-false}
    local verbose=${4:-false}
    
    log_info "Building $target version..."
    
    cd "$PROJECT_DIR"
    
    if [ "$verbose" = true ]; then
        if [ "$draft_mode" = true ]; then
            make "draft-$target" VERBOSE=1
        elif [ "$quick_mode" = true ]; then
            make "quick-$target" VERBOSE=1
        else
            make "$target" VERBOSE=1
        fi
    else
        if [ "$draft_mode" = true ]; then
            make "draft-$target" 2>/dev/null
        elif [ "$quick_mode" = true ]; then
            make "quick-$target" 2>/dev/null
        else
            make "$target" 2>/dev/null
        fi
    fi
    
    if [ $? -eq 0 ]; then
        log_success "$target version built successfully"
    else
        log_error "Failed to build $target version"
        exit 1
    fi
}

# Watch function
watch_target() {
    local target=$1
    
    log_info "Starting watch mode for $target..."
    
    if command -v entr &> /dev/null; then
        cd "$PROJECT_DIR"
        find . -name "*.tex" -o -name "*.bib" | entr -d bash "$0" "$target" --quick
    elif command -v inotifywait &> /dev/null; then
        cd "$PROJECT_DIR"
        while true; do
            inotifywait -e modify -r . --include='.*\.(tex|bib)$' && bash "$0" "$target" --quick
        done
    else
        log_error "Watch mode requires 'entr' or 'inotifywait' to be installed"
        exit 1
    fi
}

# Package for arXiv
create_arxiv_package() {
    log_info "Creating arXiv submission package..."
    
    cd "$PROJECT_DIR"
    make arxiv-package
    
    if [ $? -eq 0 ]; then
        log_success "arXiv package created in $OUTPUT_DIR/arxiv-submission.tar.gz"
    else
        log_error "Failed to create arXiv package"
        exit 1
    fi
}

# Clean function
clean_build() {
    log_info "Cleaning build files..."
    cd "$PROJECT_DIR"
    make clean-all
    log_success "Build files cleaned"
}

# Parse command line arguments
TARGET=""
DRAFT_MODE=false
QUICK_MODE=false
VERBOSE=false
WATCH_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        arxiv|journal|preprint|all|draft|quick|package|clean|watch)
            if [ "$1" = "watch" ]; then
                WATCH_MODE=true
                shift
                TARGET=$1
            else
                TARGET=$1
            fi
            ;;
        --draft)
            DRAFT_MODE=true
            ;;
        --quick)
            QUICK_MODE=true
            ;;
        --verbose)
            VERBOSE=true
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
    shift
done

# Main execution
if [ -z "$TARGET" ]; then
    log_error "No target specified"
    show_help
    exit 1
fi

check_dependencies
setup_directories

case $TARGET in
    arxiv|journal|preprint)
        if [ "$WATCH_MODE" = true ]; then
            watch_target "$TARGET"
        else
            build_target "$TARGET" "$DRAFT_MODE" "$QUICK_MODE" "$VERBOSE"
        fi
        ;;
    all)
        build_target "arxiv" "$DRAFT_MODE" "$QUICK_MODE" "$VERBOSE"
        build_target "journal" "$DRAFT_MODE" "$QUICK_MODE" "$VERBOSE"
        build_target "preprint" "$DRAFT_MODE" "$QUICK_MODE" "$VERBOSE"
        ;;
    draft)
        build_target "arxiv" true "$QUICK_MODE" "$VERBOSE"
        ;;
    quick)
        build_target "arxiv" "$DRAFT_MODE" true "$VERBOSE"
        ;;
    package)
        create_arxiv_package
        ;;
    clean)
        clean_build
        ;;
    *)
        log_error "Invalid target: $TARGET"
        show_help
        exit 1
        ;;
esac

log_success "Build process completed!"
