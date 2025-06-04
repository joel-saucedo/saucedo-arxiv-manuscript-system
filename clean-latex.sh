#!/bin/bash
#
# clean-latex.sh - LaTeX Build Artifacts Cleanup Script
# Part of the Saucedo arXiv Manuscript System
#
# Usage:
#   ./clean-latex.sh           # Clean current directory only
#   ./clean-latex.sh --all     # Clean all directories including examples
#   ./clean-latex.sh --help    # Show help

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[CLEAN]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to show help
show_help() {
    cat << EOF
LaTeX Build Artifacts Cleanup Script

Usage:
    ./clean-latex.sh [OPTIONS]

Options:
    --all       Clean all directories including examples/
    --dry-run   Show what would be deleted without actually deleting
    --help      Show this help message

Examples:
    ./clean-latex.sh                    # Clean main directory
    ./clean-latex.sh --all              # Clean everything
    ./clean-latex.sh --dry-run --all    # Preview what would be cleaned

This script removes LaTeX build artifacts like:
    .aux .log .out .bbl .blg .toc .lof .lot .fls .fdb_latexmk
    .synctex.gz .nav .snm .vrb .dvi .ps .idx .ind .ilg .glo .gls
EOF
}

# LaTeX extensions to clean
LATEX_EXTENSIONS=(
    "aux" "log" "out" "bbl" "blg" "toc" "lof" "lot" 
    "fls" "fdb_latexmk" "synctex.gz" "nav" "snm" "vrb"
    "dvi" "ps" "idx" "ind" "ilg" "glo" "gls" "glg"
    "acn" "acr" "alg" "bcf" "run.xml" "figlist" "makefile.fls"
    "figlist" "makefile" "upa" "upb" "auxlock"
)

# Function to clean directory
clean_directory() {
    local dir="$1"
    local dry_run="$2"
    
    if [[ ! -d "$dir" ]]; then
        print_warning "Directory $dir does not exist, skipping"
        return
    fi
    
    print_info "Cleaning directory: $dir"
    
    local count=0
    
    # Clean LaTeX auxiliary files
    for ext in "${LATEX_EXTENSIONS[@]}"; do
        while IFS= read -r -d '' file; do
            if [[ "$dry_run" == "true" ]]; then
                print_warning "Would delete: $file"
            else
                rm -f "$file"
                print_status "Deleted: $(basename "$file")"
            fi
            ((count++))
        done < <(find "$dir" -maxdepth 1 -name "*.$ext" -print0 2>/dev/null)
    done
    
    # Clean common LaTeX temp files with specific names
    local temp_files=(
        "texput.log"
        "missfont.log"
        ".texpadtmp"
        "*.figlist"
        "*.makefile"
        "*.fls"
        "*.fdb_latexmk"
    )
    
    for pattern in "${temp_files[@]}"; do
        while IFS= read -r -d '' file; do
            if [[ "$dry_run" == "true" ]]; then
                print_warning "Would delete: $file"
            else
                rm -f "$file"
                print_status "Deleted: $(basename "$file")"
            fi
            ((count++))
        done < <(find "$dir" -maxdepth 1 -name "$pattern" -print0 2>/dev/null)
    done
    
    if [[ $count -eq 0 ]]; then
        print_info "No LaTeX artifacts found in $dir"
    else
        if [[ "$dry_run" == "true" ]]; then
            print_info "Would clean $count files from $dir"
        else
            print_status "Cleaned $count files from $dir"
        fi
    fi
}

# Parse command line arguments
ALL_DIRS=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            ALL_DIRS=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Main execution
print_info "Starting LaTeX cleanup..."

if [[ "$DRY_RUN" == "true" ]]; then
    print_warning "DRY RUN MODE - No files will actually be deleted"
fi

# Always clean main directory
clean_directory "$SCRIPT_DIR" "$DRY_RUN"

# Clean examples if --all flag is set
if [[ "$ALL_DIRS" == "true" ]]; then
    print_info "Cleaning examples directories..."
    
    # Find all subdirectories in examples/
    if [[ -d "$SCRIPT_DIR/examples" ]]; then
        while IFS= read -r -d '' example_dir; do
            clean_directory "$example_dir" "$DRY_RUN"
        done < <(find "$SCRIPT_DIR/examples" -mindepth 1 -maxdepth 1 -type d -print0)
    else
        print_warning "Examples directory not found"
    fi
fi

if [[ "$DRY_RUN" == "true" ]]; then
    print_info "Dry run completed. Use without --dry-run to actually clean files."
else
    print_status "LaTeX cleanup completed!"
fi

print_info "To clean everything: ./clean-latex.sh --all"
print_info "To preview changes: ./clean-latex.sh --dry-run --all"
