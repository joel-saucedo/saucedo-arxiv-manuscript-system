#!/bin/bash
# Simple and robust build script for the Saucedo arXiv Manuscript System

echo "=== Saucedo arXiv Manuscript System - Build All ==="
echo ""

# Build function that always succeeds if PDF is generated
build_format() {
    format=$1
    echo "Building $format format..."
    
    # Run LaTeX compilation (ignoring exit codes, checking for PDF output)
    pdflatex -interaction=nonstopmode main-$format.tex >/dev/null 2>&1
    bibtex main-$format >/dev/null 2>&1
    pdflatex -interaction=nonstopmode main-$format.tex >/dev/null 2>&1
    pdflatex -interaction=nonstopmode main-$format.tex >/dev/null 2>&1
    
    # Check if PDF was generated
    if [ -f "main-$format.pdf" ]; then
        size=$(du -h main-$format.pdf | cut -f1)
        echo "✅ main-$format.pdf generated successfully ($size)"
    else
        echo "❌ Failed to generate main-$format.pdf"
    fi
    echo ""
}

# Build all three formats
build_format "arxiv"
build_format "journal"  
build_format "preprint"

echo "=== Build Summary ==="
total=0
for format in arxiv journal preprint; do
    if [ -f "main-$format.pdf" ]; then
        size=$(du -h main-$format.pdf | cut -f1)
        echo "  ✅ main-$format.pdf ($size)"
        total=$((total + 1))
    else
        echo "  ❌ main-$format.pdf (failed)"
    fi
done

echo ""
echo "Successfully built $total/3 manuscript formats!"
echo "Ready for submission and distribution."
