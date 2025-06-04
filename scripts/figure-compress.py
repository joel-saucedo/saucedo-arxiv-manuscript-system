#!/usr/bin/env python3
"""
figure-compress.py - Intelligent figure compression for arXiv submissions
Part of the Saucedo arXiv Manuscript System

This script automatically compresses figures to meet arXiv size requirements
while maintaining visual quality for academic publications.
"""

import os
import sys
import argparse
import shutil
from pathlib import Path
from PIL import Image, ImageOpt
import subprocess

# Configuration
MAX_FILE_SIZE_MB = 10  # arXiv submission limit
TARGET_DPI = 300      # Target DPI for figures
QUALITY_JPEG = 85     # JPEG quality (0-100)
QUALITY_PNG = 9       # PNG compression level (0-9)

class FigureCompressor:
    def __init__(self, input_dir, output_dir, verbose=False):
        self.input_dir = Path(input_dir)
        self.output_dir = Path(output_dir)
        self.verbose = verbose
        
        # Create output directory if it doesn't exist
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Supported formats
        self.image_formats = {'.png', '.jpg', '.jpeg', '.tiff', '.tif', '.bmp'}
        self.vector_formats = {'.pdf', '.eps', '.svg'}
        
    def log(self, message):
        if self.verbose:
            print(f"[INFO] {message}")
            
    def get_file_size_mb(self, filepath):
        """Get file size in MB"""
        return os.path.getsize(filepath) / (1024 * 1024)
    
    def compress_raster_image(self, input_path, output_path):
        """Compress raster images (PNG, JPEG, etc.)"""
        try:
            with Image.open(input_path) as img:
                # Convert to RGB if necessary
                if img.mode in ('RGBA', 'LA', 'P'):
                    if input_path.suffix.lower() in ['.jpg', '.jpeg']:
                        # Convert to RGB for JPEG
                        rgb_img = Image.new('RGB', img.size, (255, 255, 255))
                        if img.mode == 'P':
                            img = img.convert('RGBA')
                        rgb_img.paste(img, mask=img.split()[-1] if img.mode in ('RGBA', 'LA') else None)
                        img = rgb_img
                
                # Determine output format and compression
                if output_path.suffix.lower() in ['.jpg', '.jpeg']:
                    img.save(output_path, 'JPEG', quality=QUALITY_JPEG, optimize=True, progressive=True)
                elif output_path.suffix.lower() == '.png':
                    img.save(output_path, 'PNG', optimize=True, compress_level=QUALITY_PNG)
                else:
                    # Keep original format
                    img.save(output_path, optimize=True)
                    
                return True
        except Exception as e:
            print(f"Error compressing {input_path}: {e}")
            return False
    
    def compress_vector_graphic(self, input_path, output_path):
        """Compress vector graphics (PDF, EPS)"""
        try:
            if input_path.suffix.lower() == '.pdf':
                # Use Ghostscript to compress PDF
                cmd = [
                    'gs', '-sDEVICE=pdfwrite', '-dCompatibilityLevel=1.4',
                    '-dPDFSETTINGS=/prepress', '-dNOPAUSE', '-dQUIET', '-dBATCH',
                    f'-sOutputFile={output_path}', str(input_path)
                ]
                
                result = subprocess.run(cmd, capture_output=True, text=True)
                if result.returncode == 0:
                    return True
                else:
                    self.log(f"Ghostscript error: {result.stderr}")
                    # Fallback: just copy the file
                    shutil.copy2(input_path, output_path)
                    return True
                    
            elif input_path.suffix.lower() in ['.eps', '.svg']:
                # For EPS and SVG, just copy (could add specific compression later)
                shutil.copy2(input_path, output_path)
                return True
                
        except Exception as e:
            print(f"Error compressing vector graphic {input_path}: {e}")
            # Fallback: copy original
            shutil.copy2(input_path, output_path)
            return False
    
    def process_file(self, input_path):
        """Process a single file"""
        relative_path = input_path.relative_to(self.input_dir)
        output_path = self.output_dir / relative_path
        
        # Create output subdirectories if needed
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Get original file size
        original_size = self.get_file_size_mb(input_path)
        
        self.log(f"Processing {relative_path} ({original_size:.2f} MB)")
        
        # Determine file type and compress accordingly
        suffix = input_path.suffix.lower()
        
        if suffix in self.image_formats:
            success = self.compress_raster_image(input_path, output_path)
        elif suffix in self.vector_formats:
            success = self.compress_vector_graphic(input_path, output_path)
        else:
            # Copy other files as-is
            shutil.copy2(input_path, output_path)
            success = True
        
        if success and output_path.exists():
            compressed_size = self.get_file_size_mb(output_path)
            compression_ratio = (1 - compressed_size / original_size) * 100 if original_size > 0 else 0
            
            self.log(f"  → {compressed_size:.2f} MB ({compression_ratio:.1f}% reduction)")
            
            # Check if file is still too large
            if compressed_size > MAX_FILE_SIZE_MB:
                print(f"WARNING: {relative_path} is still {compressed_size:.2f} MB (exceeds {MAX_FILE_SIZE_MB} MB limit)")
        
        return success
    
    def compress_all(self):
        """Compress all figures in the input directory"""
        print(f"Compressing figures from {self.input_dir} to {self.output_dir}")
        print(f"Target: files ≤ {MAX_FILE_SIZE_MB} MB")
        print()
        
        # Find all figure files
        figure_files = []
        for pattern in ['**/*' + ext for ext in (self.image_formats | self.vector_formats)]:
            figure_files.extend(self.input_dir.glob(pattern))
        
        if not figure_files:
            print("No figure files found to compress.")
            return
        
        # Process each file
        successful = 0
        total_original_size = 0
        total_compressed_size = 0
        
        for file_path in sorted(figure_files):
            if file_path.is_file():
                original_size = self.get_file_size_mb(file_path)
                total_original_size += original_size
                
                if self.process_file(file_path):
                    successful += 1
                    output_file = self.output_dir / file_path.relative_to(self.input_dir)
                    if output_file.exists():
                        total_compressed_size += self.get_file_size_mb(output_file)
        
        # Summary
        print()
        print(f"Compression Summary:")
        print(f"  Files processed: {successful}/{len(figure_files)}")
        print(f"  Total original size: {total_original_size:.2f} MB")
        print(f"  Total compressed size: {total_compressed_size:.2f} MB")
        if total_original_size > 0:
            overall_reduction = (1 - total_compressed_size / total_original_size) * 100
            print(f"  Overall reduction: {overall_reduction:.1f}%")

def main():
    parser = argparse.ArgumentParser(
        description="Compress figures for arXiv submission",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                           # Compress figures/high-res/ to figures/compressed/
  %(prog)s --input custom/           # Compress custom/ directory
  %(prog)s --output small/           # Output to small/ directory
  %(prog)s --quality 90              # Use JPEG quality 90
  %(prog)s --max-size 5              # Set max file size to 5 MB
        """
    )
    
    parser.add_argument('--input', '-i', 
                       default='figures/high-res',
                       help='Input directory (default: figures/high-res)')
    
    parser.add_argument('--output', '-o',
                       default='figures/compressed', 
                       help='Output directory (default: figures/compressed)')
    
    parser.add_argument('--quality', '-q',
                       type=int, default=QUALITY_JPEG,
                       help=f'JPEG quality 0-100 (default: {QUALITY_JPEG})')
    
    parser.add_argument('--max-size', '-m',
                       type=float, default=MAX_FILE_SIZE_MB,
                       help=f'Maximum file size in MB (default: {MAX_FILE_SIZE_MB})')
    
    parser.add_argument('--verbose', '-v',
                       action='store_true',
                       help='Verbose output')
    
    args = parser.parse_args()
    
    # Update global settings
    global QUALITY_JPEG, MAX_FILE_SIZE_MB
    QUALITY_JPEG = args.quality
    MAX_FILE_SIZE_MB = args.max_size
    
    # Check if input directory exists
    if not Path(args.input).exists():
        print(f"Error: Input directory '{args.input}' does not exist.")
        sys.exit(1)
    
    # Run compression
    compressor = FigureCompressor(args.input, args.output, args.verbose)
    compressor.compress_all()

if __name__ == '__main__':
    main()
