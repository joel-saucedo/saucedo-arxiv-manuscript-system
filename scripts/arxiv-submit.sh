#!/bin/bash
# arxiv-submit.sh - Prepares arXiv submission package

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_DIR/output"

log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

log_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

show_help() {
    echo "arXiv Submission Preparation Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --check-size    Check if package meets arXiv size limits"
    echo "  --validate      Validate submission package"
    echo "  --help          Show this help message"
    echo ""
    echo "This script prepares a complete arXiv submission package including:"
    echo "  - Main LaTeX files"
    echo "  - All content and configuration files"
    echo "  - Compressed figures"
    echo "  - Bibliography files"
    echo "  - Custom class files"
}

# Check arXiv size limits (50MB for source, 1GB total)
check_size_limits() {
    local package_dir="$OUTPUT_DIR/arxiv-submission"
    
    if [ ! -d "$package_dir" ]; then
        log_warning "arXiv submission package not found. Run 'make arxiv-package' first."
        return 1
    fi
    
    # Check source size (excluding PDFs)
    local source_size=$(find "$package_dir" -type f ! -name "*.pdf" -exec du -cb {} + | tail -1 | cut -f1)
    local source_size_mb=$((source_size / 1024 / 1024))
    
    # Check total size
    local total_size=$(du -sb "$package_dir" | cut -f1)
    local total_size_mb=$((total_size / 1024 / 1024))
    
    log_info "Package size check:"
    echo "  Source files: ${source_size_mb}MB (limit: 50MB)"
    echo "  Total size: ${total_size_mb}MB (limit: 1024MB)"
    
    if [ $source_size_mb -gt 50 ]; then
        log_warning "Source files exceed 50MB limit!"
        return 1
    fi
    
    if [ $total_size_mb -gt 1024 ]; then
        log_warning "Total package exceeds 1GB limit!"
        return 1
    fi
    
    log_success "Package size within arXiv limits"
    return 0
}

# Validate submission package
validate_package() {
    local package_dir="$OUTPUT_DIR/arxiv-submission"
    
    if [ ! -d "$package_dir" ]; then
        log_warning "arXiv submission package not found. Run 'make arxiv-package' first."
        return 1
    fi
    
    log_info "Validating arXiv submission package..."
    
    # Check required files
    local required_files=(
        "main-arxiv.tex"
        "arxiv-preprint.cls"
        "bibliography/refs.bib"
        "content/abstract.tex"
        "content/introduction.tex"
    )
    
    local missing_files=()
    for file in "${required_files[@]}"; do
        if [ ! -f "$package_dir/$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        log_warning "Missing required files:"
        printf '  %s\n' "${missing_files[@]}"
        return 1
    fi
    
    # Check for problematic files
    local problematic_files=$(find "$package_dir" -name "*.aux" -o -name "*.log" -o -name "*.synctex.gz")
    if [ -n "$problematic_files" ]; then
        log_warning "Found auxiliary files that should be removed:"
        echo "$problematic_files"
    fi
    
    log_success "Package validation complete"
    return 0
}

# Main execution
case ${1:-""} in
    --check-size)
        check_size_limits
        ;;
    --validate)
        validate_package
        ;;
    --help|-h)
        show_help
        ;;
    "")
        log_info "Preparing arXiv submission..."
        cd "$PROJECT_DIR"
        make arxiv-package
        validate_package
        check_size_limits
        
        if [ $? -eq 0 ]; then
            log_success "arXiv submission package ready!"
            echo ""
            echo "Next steps:"
            echo "1. Extract: tar -xzf $OUTPUT_DIR/arxiv-submission.tar.gz"
            echo "2. Test build in clean environment"
            echo "3. Submit to arXiv: https://arxiv.org/submit"
        fi
        ;;
    *)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
