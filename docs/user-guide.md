# Saucedo arXiv Manuscript System - User Guide

## Quick Start

### 1. Setting Up Your Manuscript

1. **Clone the repository:**
   ```bash
   git clone https://github.com/joel-saucedo/saucedo-arxiv-manuscript-system.git
   cd saucedo-arxiv-manuscript-system
   ```

2. **Edit your content:**
   - Modify `content/abstract.tex` with your abstract
   - Update `content/introduction.tex`, `content/methodology.tex`, etc.
   - Add your references to `bibliography/refs.bib`
   - Place figures in `figures/high-res/` and `figures/compressed/`

3. **Update main files:**
   - Edit `main-arxiv.tex` for arXiv submission
   - Edit `main-journal.tex` for journal submission
   - Customize title, authors, and metadata

### 2. Building Your Manuscript

#### Using Make (Recommended)
```bash
# Build all versions
make all

# Build specific versions
make arxiv          # arXiv optimized
make journal        # Journal submission
make preprint       # Draft with watermarks

# Quick builds (single pass)
make quick-arxiv
make quick-journal

# Draft versions (with line numbers)
make draft-arxiv
make draft-journal
```

#### Using Build Script
```bash
# Build arXiv version
./build/build.sh arxiv

# Build with draft features
./build/build.sh arxiv --draft

# Quick build
./build/build.sh arxiv --quick

# Watch for changes and rebuild
./build/build.sh watch arxiv
```

### 3. Managing Figures

#### High-Resolution for Journals
Place your high-quality figures in `figures/high-res/`:
- Use PNG, PDF, or EPS formats
- Maintain original resolution
- Used automatically for journal builds

#### Compressed for arXiv
Generate compressed versions:
```bash
./scripts/figure-compress.sh
```

This creates optimized versions in `figures/compressed/` that meet arXiv size limits.

### 4. Preparing for Submission

#### arXiv Submission
```bash
# Create submission package
make arxiv-package

# Validate and check size
./scripts/arxiv-submit.sh --validate
./scripts/arxiv-submit.sh --check-size

# Complete preparation
./scripts/arxiv-submit.sh
```

This creates `output/arxiv-submission.tar.gz` ready for arXiv upload.

#### Journal Submission
```bash
# Build journal version
make journal

# The PDF will be in output/main-journal.pdf
```

## Document Classes and Options

### Class Options

The `arxiv-preprint` class supports several options:

```latex
\documentclass[OPTIONS]{arxiv-preprint}
```

**Target Options:**
- `arxiv` - Optimized for arXiv (default)
- `journal` - Optimized for journal submission

**Mode Options:**
- `draft` - Enables line numbers, watermarks, comments
- `final` - Clean final version (default)

**Layout Options:**
- `onecolumn` - Single column layout (default)
- `twocolumn` - Two column layout
- `oneside` - Single-sided (default)
- `twoside` - Double-sided for printing

### Configuration Files

#### `config/shared-packages.tex`
Common packages used across all versions:
- Mathematics: `amsmath`, `amsthm`, `mathtools`
- Graphics: `graphicx`, `tikz`, `subcaption`
- Typography: Enhanced fonts and spacing
- Cross-references: `hyperref`, `cleveref`

#### `config/arxiv-config.tex`
arXiv-specific settings:
- Letter paper, 1-inch margins
- Enhanced hyperlinks with colors
- Compact theorem environments
- Figure paths point to `figures/compressed/`

#### `config/journal-config.tex`
Journal-specific settings:
- A4 paper, conservative margins
- Professional two-sided layout
- Conservative hyperlink styling
- Figure paths point to `figures/high-res/`

## Content Organization

### Main Content Files

All content is modularized in the `content/` directory:

- `abstract.tex` - Your manuscript abstract
- `introduction.tex` - Introduction section
- `methodology.tex` - Methods and approach
- `results.tex` - Results and findings
- `discussion.tex` - Discussion and analysis
- `conclusion.tex` - Conclusions and future work
- `appendix.tex` - Supplementary material

### Bibliography Management

Use `bibliography/refs.bib` for all references:

```bibtex
@article{author2023,
    title={Title of the Paper},
    author={Author, First and Author, Second},
    journal={Journal Name},
    volume={1},
    pages={1--10},
    year={2023},
    doi={10.1000/182}
}
```

## Advanced Features

### Conditional Content

Use conditional commands to include content only in specific builds:

```latex
\arxivonly{This appears only in arXiv builds}
\journalonly{This appears only in journal builds}
\draftonly{This appears only in draft mode}
```

### Custom Commands

The system provides many convenience commands:

```latex
% Cross-references
\figref{fig:example}    % "Figure 1"
\tabref{tab:data}       % "Table 1"  
\eqref{eq:einstein}     % "Equation (1)"
\secref{sec:intro}      % "Section 1"

% Mathematics
\vect{v}               % Bold vector
\uvect{n}              % Unit vector
\abs{x}                % Absolute value
\norm{v}               % Vector norm
\dd{f}{x}              % Derivative df/dx
\pd{f}{x}              % Partial derivative
```

### Version Control Integration

The system integrates with Git:

```bash
# Generate version information
./scripts/version-stamp.sh

# This creates .version-info with:
# - Git commit hash
# - Branch name
# - Build date
```

### Watch Mode

For rapid development, use watch mode:

```bash
# Automatically rebuild on changes
make watch-arxiv
# or
./build/build.sh watch arxiv
```

## Troubleshooting

### Common Build Issues

1. **Missing LaTeX packages:**
   ```bash
   # On Ubuntu/Debian
   sudo apt install texlive-full
   
   # On macOS
   brew install --cask mactex
   ```

2. **Bibliography not showing:**
   - Ensure `refs.bib` has valid entries
   - Run full build (not quick build)
   - Check for BibTeX errors in build output

3. **Figures not appearing:**
   - Check file paths in LaTeX files
   - Ensure figures exist in correct directories
   - Verify figure file extensions

### Build Errors

Enable verbose output for debugging:
```bash
./build/build.sh arxiv --verbose
```

### Cleaning Build Files

```bash
# Clean build artifacts
make clean

# Clean everything including outputs
make clean-all

# Or use the cleaning script
./build/clean.sh --all
```

## Customization

### Journal-Specific Adaptations

For specific journals, modify `main-journal.tex`:

```latex
% For Nature journals
\journalonly{
    \usepackage{natbib}
    \bibliographystyle{naturemag}
}

% For ACS journals  
\journalonly{
    \usepackage{achemso}
    \bibliographystyle{achemso}
}
```

### Custom Theorem Environments

Add custom environments in your config files:

```latex
\newtheoremstyle{custom}
    {6pt}{6pt}{\itshape}{0pt}{\bfseries}{.}{.5em}{}

\theoremstyle{custom}
\newtheorem{hypothesis}[theorem]{Hypothesis}
```

### Figure Compression Settings

Modify `scripts/figure-compress.sh` to adjust compression:

```bash
# Change quality (1-100)
convert "$file" -quality 90 -resize 2048x2048\> "$output"

# Change maximum dimensions
convert "$file" -quality 85 -resize 4096x4096\> "$output"
```

## Best Practices

1. **Version Control**: Always use Git for your manuscript
2. **Incremental Builds**: Use quick builds during development
3. **Figure Organization**: Keep originals separate from compressed
4. **Regular Validation**: Test arXiv packages before submission
5. **Backup**: Keep multiple backups of your work

## Getting Help

- Check the documentation in `docs/`
- Review example papers in `examples/`
- Open issues on GitHub for bugs or feature requests
- Read LaTeX error messages carefully - they're usually helpful!
