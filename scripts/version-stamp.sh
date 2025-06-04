#!/bin/bash
# version-stamp.sh - Automatic version stamping for manuscripts
# Part of the Saucedo arXiv Manuscript System

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$PROJECT_DIR/.version"
CHANGELOG_FILE="$PROJECT_DIR/CHANGELOG.md"

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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    echo "Version Stamping Script for Saucedo arXiv Manuscript System"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  major          Increment major version (x.0.0)"
    echo "  minor          Increment minor version (x.y.0)"
    echo "  patch          Increment patch version (x.y.z)"
    echo "  set VERSION    Set specific version (e.g., 1.2.3)"
    echo "  show           Show current version"
    echo "  stamp          Add version stamps to documents"
    echo ""
    echo "Options:"
    echo "  --message MSG  Changelog message"
    echo "  --tag          Create git tag"
    echo "  --help         Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 minor --message \"Added new features\""
    echo "  $0 patch --message \"Bug fixes\" --tag"
    echo "  $0 set 2.1.0 --message \"Major release\""
}

# Get current version
get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "0.1.0"
    fi
}

# Set version
set_version() {
    local version=$1
    echo "$version" > "$VERSION_FILE"
    log_success "Version set to $version"
}

# Validate version format
validate_version() {
    local version=$1
    if ! [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_error "Invalid version format: $version (expected: x.y.z)"
        return 1
    fi
    return 0
}

# Increment version
increment_version() {
    local current_version=$(get_current_version)
    local version_type=$1
    
    IFS='.' read -ra VERSION_PARTS <<< "$current_version"
    local major=${VERSION_PARTS[0]}
    local minor=${VERSION_PARTS[1]}
    local patch=${VERSION_PARTS[2]}
    
    case $version_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            log_error "Unknown version type: $version_type"
            return 1
            ;;
    esac
    
    echo "$major.$minor.$patch"
}

# Update changelog
update_changelog() {
    local version=$1
    local message=$2
    local date=$(date '+%Y-%m-%d')
    
    if [ ! -f "$CHANGELOG_FILE" ]; then
        cat > "$CHANGELOG_FILE" << EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

EOF
    fi
    
    # Create temporary file with new entry
    local temp_file=$(mktemp)
    
    # Add new entry after the header
    head -n 6 "$CHANGELOG_FILE" > "$temp_file"
    echo "" >> "$temp_file"
    echo "## [$version] - $date" >> "$temp_file"
    echo "" >> "$temp_file"
    echo "### Changed" >> "$temp_file"
    echo "- $message" >> "$temp_file"
    echo "" >> "$temp_file"
    
    # Add existing content (skip header)
    tail -n +7 "$CHANGELOG_FILE" >> "$temp_file"
    
    # Replace original file
    mv "$temp_file" "$CHANGELOG_FILE"
    
    log_success "Updated changelog with version $version"
}

# Get git information
get_git_info() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local commit_hash=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
        local commit_date=$(git log -1 --format=%cd --date=short 2>/dev/null || date '+%Y-%m-%d')
        
        echo "commit:$commit_hash,branch:$branch,date:$commit_date"
    else
        echo "commit:unknown,branch:unknown,date:$(date '+%Y-%m-%d')"
    fi
}

# Stamp documents with version information
stamp_documents() {
    local version=$(get_current_version)
    local git_info=$(get_git_info)
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    log_info "Stamping documents with version $version..."
    
    # Create version info file
    local version_info_file="$PROJECT_DIR/config/version-info.tex"
    
    cat > "$version_info_file" << EOF
%% version-info.tex
%% Automatically generated version information
%% Generated on: $timestamp

\\newcommand{\\manuscriptversion}{$version}
\\newcommand{\\manuscripttimestamp}{$timestamp}
\\newcommand{\\manuscriptgitinfo}{$git_info}

% Version-dependent commands
\\newcommand{\\versionstamp}{%
    \\arxivonly{%
        \\footnotetext[0]{%
            \\textcolor{gray}{%
                \\tiny Version $version -- $timestamp%
            }%
        }%
    }%
}

% Draft watermark with version
\\draftonly{%
    \\usepackage{draftwatermark}%
    \\SetWatermarkText{DRAFT v$version}%
    \\SetWatermarkScale{0.8}%
    \\SetWatermarkColor[gray]{0.9}%
}
EOF
    
    log_success "Version information written to config/version-info.tex"
    
    # Update main template files to include version info
    for template in "$PROJECT_DIR"/main-*.tex; do
        if [ -f "$template" ]; then
            # Check if version-info is already included
            if ! grep -q "version-info" "$template"; then
                # Add version info include after shared-packages
                sed -i '/\\input{config\/shared-packages}/a \\input{config/version-info}' "$template"
                log_info "Added version info to $(basename "$template")"
            fi
        fi
    done
}

# Create git tag
create_git_tag() {
    local version=$1
    local message=$2
    
    if git rev-parse --git-dir > /dev/null 2>&1; then
        git add .
        git commit -m "Version $version: $message" || true
        git tag -a "v$version" -m "Version $version: $message"
        log_success "Created git tag v$version"
    else
        log_warning "Not a git repository, skipping tag creation"
    fi
}

# Main execution
COMMAND=""
MESSAGE=""
CREATE_TAG=false

while [[ $# -gt 0 ]]; do
    case $1 in
        major|minor|patch|show|stamp)
            COMMAND=$1
            ;;
        set)
            COMMAND=$1
            shift
            NEW_VERSION=$1
            ;;
        --message)
            shift
            MESSAGE=$1
            ;;
        --tag)
            CREATE_TAG=true
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

if [ -z "$COMMAND" ]; then
    show_help
    exit 1
fi

cd "$PROJECT_DIR"

case $COMMAND in
    show)
        current_version=$(get_current_version)
        echo "Current version: $current_version"
        if [ -f "$VERSION_FILE" ]; then
            echo "Version file: $VERSION_FILE"
        else
            echo "Version file: not found (using default)"
        fi
        ;;
        
    major|minor|patch)
        new_version=$(increment_version "$COMMAND")
        set_version "$new_version"
        
        if [ -n "$MESSAGE" ]; then
            update_changelog "$new_version" "$MESSAGE"
        else
            update_changelog "$new_version" "Version $COMMAND update"
        fi
        
        stamp_documents
        
        if [ "$CREATE_TAG" = true ]; then
            create_git_tag "$new_version" "${MESSAGE:-Version $COMMAND update}"
        fi
        ;;
        
    set)
        if [ -z "$NEW_VERSION" ]; then
            log_error "Version number required for 'set' command"
            exit 1
        fi
        
        if ! validate_version "$NEW_VERSION"; then
            exit 1
        fi
        
        set_version "$NEW_VERSION"
        
        if [ -n "$MESSAGE" ]; then
            update_changelog "$NEW_VERSION" "$MESSAGE"
        else
            update_changelog "$NEW_VERSION" "Version set to $NEW_VERSION"
        fi
        
        stamp_documents
        
        if [ "$CREATE_TAG" = true ]; then
            create_git_tag "$NEW_VERSION" "${MESSAGE:-Version set to $NEW_VERSION}"
        fi
        ;;
        
    stamp)
        stamp_documents
        ;;
        
    *)
        log_error "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac

log_success "Version stamping completed!"
fi

# Get git information
GIT_HASH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown")
GIT_BRANCH=$(git -C "$PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
GIT_DATE=$(git -C "$PROJECT_DIR" log -1 --format=%cd --date=short 2>/dev/null || date +%Y-%m-%d)
BUILD_DATE=$(date +%Y-%m-%d)

# Create version info file
VERSION_FILE="$PROJECT_DIR/.version-info"

cat > "$VERSION_FILE" << EOF
% Auto-generated version information
% Generated on: $BUILD_DATE

\newcommand{\projectversion}{v1.0}
\newcommand{\githash}{$GIT_HASH}
\newcommand{\gitbranch}{$GIT_BRANCH}
\newcommand{\gitdate}{$GIT_DATE}
\newcommand{\builddate}{$BUILD_DATE}
EOF

echo "Version information updated in $VERSION_FILE"
echo "Git Hash: $GIT_HASH"
echo "Branch: $GIT_BRANCH"
echo "Last Commit: $GIT_DATE"
echo "Build Date: $BUILD_DATE"
