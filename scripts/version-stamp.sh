#!/bin/bash
# version-stamp.sh - Adds version information to manuscripts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Check if we're in a git repository
if ! git -C "$PROJECT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    echo "Not a git repository. Initialize git first:"
    echo "cd $PROJECT_DIR && git init"
    exit 1
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
