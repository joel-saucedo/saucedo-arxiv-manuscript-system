# Saucedo arXiv Manuscript System

A sophisticated LaTeX document class and workflow system for dual-target academic publishing, optimized for both journal submissions and arXiv preprints.

## Current Status - FULLY WORKING

This system has been recently updated and all core functionality is operational:
- All three manuscript formats compile successfully
- Clean, minimal document class (`arxiv-preprint-simple.cls`)
- Robust build system with simple workflow
- Complete content structure and examples

## Quick Start

```bash
# Clone the repository
git clone https://github.com/joel-saucedo/saucedo-arxiv-manuscript-system.git
cd saucedo-arxiv-manuscript-system

# Build all manuscript formats
./build-simple.sh

# Or build individual formats
pdflatex main-arxiv.tex      # arXiv version
pdflatex main-journal.tex    # Journal version  
pdflatex main-preprint.tex   # Preprint/draft version
```

### Output
- `main-arxiv.pdf` - arXiv-optimized format
- `main-journal.pdf` - Journal submission format
- `main-preprint.pdf` - Draft version with review features

## Features

### Core Capabilities
- **Dual-Target System**: Generate both journal and arXiv versions from the same source
- **Smart Document Class**: Automatically adapts formatting based on target
- **Modular Content**: Shared content files with conditional compilation
- **Automated Build System**: One-command builds with multiple output formats
- **Professional Typography**: Journal-quality formatting with arXiv optimization

### Advanced Features
- **Intelligent Figure Management**: Automatic compression and path switching
- **Enhanced Cross-Referencing**: Smart reference commands for equations, figures, tables
- **Draft Mode**: Line numbering, watermarks, and review-friendly features
- **Version Control Integration**: Automatic Git information embedding
- **Comprehensive Build Tools**: Makefile and shell scripts for automation

## Structure

```
saucedo-arxiv-manuscript-system/
├── main-arxiv.tex           # arXiv-optimized template
├── main-journal.tex         # Journal submission template  
├── main-preprint.tex        # Draft/preprint template
├── arxiv-preprint-simple.cls # Core document class (working version)
├── build-simple.sh          # Simple build script for all formats
├── content/                 # Modular content files
│   ├── abstract.tex
│   ├── introduction.tex
│   ├── methodology.tex
│   ├── results.tex
│   ├── discussion.tex
│   ├── conclusion.tex
│   └── appendix.tex
├── config/                  # Configuration files
│   ├── shared-packages.tex  # Common packages
│   ├── arxiv-config.tex     # arXiv-specific settings
│   └── journal-config.tex   # Journal-specific settings
├── bibliography/            # Bibliography management
│   └── refs.bib
├── figures/                 # Figure directories
│   ├── high-res/           # Journal-quality figures
│   └── compressed/         # arXiv-optimized figures
├── build/                   # Build system
│   ├── Makefile
│   ├── build.sh
│   └── clean.sh
└── examples/               # Example papers
```

## Quick Start

### Prerequisites
- LaTeX distribution (TeX Live, MiKTeX, or MacTeX)
- `pdflatex` and `bibtex`
- Optional: `entr` or `inotifywait` for watch mode

### Installation
```bash
git clone https://github.com/joel-saucedo/saucedo-arxiv-manuscript-system.git
cd saucedo-arxiv-manuscript-system
chmod +x build/build.sh build/clean.sh
```

### Basic Usage

#### Using the Build Script
```bash
# Build arXiv version
./build/build.sh arxiv

# Build journal version
./build/build.sh journal

# Build all versions
./build/build.sh all

# Build draft with line numbers
./build/build.sh arxiv --draft

# Quick build (single pass)
./build/build.sh arxiv --quick

# Watch mode (auto-rebuild on changes)
./build/build.sh watch arxiv
```

#### Using Make
```bash
# Build specific versions
make arxiv
make journal
make preprint

# Build all versions
make all

# Create arXiv submission package
make arxiv-package

# Clean build files
make clean
```

## Document Class Usage

### Basic Document Setup

**arXiv Version:**
```latex
\documentclass[arxiv,final,oneside,onecolumn]{arxiv-preprint}
\input{config/shared-packages}
\input{config/arxiv-config}
```

**Journal Version:**
```latex
\documentclass[journal,final,twoside,onecolumn]{arxiv-preprint}
\input{config/shared-packages}
\input{config/journal-config}
```

**Draft Version:**
```latex
\documentclass[arxiv,draft,oneside,onecolumn]{arxiv-preprint}
\input{config/shared-packages}
\input{config/arxiv-config}
```

### Class Options

| Option | Description |
|--------|-------------|
| `arxiv` | Optimize for arXiv preprints |
| `journal` | Optimize for journal submissions |
| `draft` | Enable draft features (line numbers, watermarks) |
| `final` | Disable draft features |
| `oneside` / `twoside` | Page layout |
| `onecolumn` / `twocolumn` | Column layout |

### Conditional Content

Use these commands to include content only in specific targets:

```latex
\arxivonly{This appears only in arXiv version}
\journalonly{This appears only in journal version}
\draftonly{This appears only in draft mode}

% Example usage
\arxivonly{
    \section*{Preprint Notice}
    This is a preprint submitted to arXiv.
}

\journalonly{
    \section*{Conflict of Interest}
    The authors declare no conflict of interest.
}
```

### Enhanced References

The system provides smart cross-referencing commands:

```latex
\figref{fig:example}    % → Figure 1
\tabref{tab:results}    % → Table 2  
\eqref{eq:main}         % → Equation (3)
\secref{sec:method}     % → Section 2
\appref{app:proofs}     % → Appendix A
```

## Customization

### Journal-Specific Adaptations

The system can be easily adapted for specific journals by modifying `config/journal-config.tex`:

```latex
% For Nature journals
\usepackage{natbib}
\bibliographystyle{naturemag}

% For ACS journals  
\usepackage{achemso}
\bibliographystyle{achemso}

% For IEEE journals
\bibliographystyle{IEEEtran}
```

### Figure Management

Place figures in appropriate directories:
- `figures/high-res/`: High-resolution figures for journal submission
- `figures/compressed/`: Compressed figures for arXiv (size limits)

The document class automatically selects the correct path based on the target.

### Bibliography Styles

Multiple bibliography styles are supported in `bibliography/styles/`. The system automatically selects appropriate styles based on the target format.

## Advanced Features

### Build System Options

The build system supports various advanced options:

```bash
# Verbose output
./build/build.sh arxiv --verbose

# Watch mode with automatic rebuilds
./build/build.sh watch journal

# Create submission package
make arxiv-package
```

### Version Control Integration

The system integrates with Git to embed version information:

```latex
% Automatic version information
\draftonly{
    Build: \today\\
    Commit: \gitAbbrevHash
}
```

### Multi-Format Output

Generate multiple formats simultaneously:

```bash
make all  # Builds arxiv, journal, and preprint versions
```

## Examples

The `examples/` directory contains complete example papers demonstrating:
- Physics paper with complex equations
- Mathematics paper with theorem environments
- Multi-author collaboration setup
- Conference paper adaptation

## Contributing

Contributions are welcome! Please see our contribution guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with example documents
5. Submit a pull request

### Development Setup

```bash
git clone https://github.com/joel-saucedo/saucedo-arxiv-manuscript-system.git
cd saucedo-arxiv-manuscript-system
# Make changes and test
./build/build.sh all --verbose
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by modern academic publishing workflows
- Built on the robust LaTeX ecosystem
- Community feedback and contributions

## Documentation

For detailed documentation, see:
- [User Guide](docs/user-guide.md)
- [Class Documentation](docs/class-documentation.md)
- [Workflow Examples](docs/workflow-examples.md)

## Issues and Support

- Report issues on [GitHub Issues](https://github.com/joel-saucedo/saucedo-arxiv-manuscript-system/issues)
- For questions, use [GitHub Discussions](https://github.com/joel-saucedo/saucedo-arxiv-manuscript-system/discussions)

## Related Projects

- [arXiv submission guidelines](https://arxiv.org/help/submit)
- [Journal formatting requirements](https://www.latex-project.org/)
- [Academic writing best practices](https://writing.wisc.edu/handbook/)

---

**Saucedo arXiv Manuscript System** - Streamlining academic publishing workflows for the modern researcher.
