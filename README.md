# Saucedo arXiv-Friendly Manuscript System

A sophisticated LaTeX manuscript system designed for modern academic publishing workflows. This system enables seamless generation of both journal-ready submissions and arXiv preprints from a single source.

## 🚀 Features

### Dual-Target Publishing
- **Journal Mode**: Optimized for high-impact journals (Springer Nature, APS, etc.)
- **arXiv Mode**: Optimized for preprint servers with size limits and hyperlinks
- **Single Source**: Maintain one set of content files for both targets

### Professional Typography
- Advanced mathematical typesetting with custom theorem environments
- Intelligent figure management with automatic compression
- Multi-style bibliography support (Nature, APS, Vancouver, Chicago)
- Professional cross-referencing and citation systems

### Smart Build System
- Automated PDF generation for multiple targets
- Git integration with version stamping
- Intelligent figure path switching
- Conditional content inclusion

## 📁 Project Structure

```
manuscript-system/
├── main-journal.tex          # Journal submission version
├── main-arxiv.tex           # arXiv preprint version  
├── arxiv-preprint.cls       # Custom arXiv-optimized class
├── content/                 # Shared content files
│   ├── abstract.tex
│   ├── introduction.tex
│   ├── methodology.tex
│   ├── results.tex
│   ├── discussion.tex
│   ├── conclusion.tex
│   └── appendix.tex
├── config/
│   ├── journal-config.tex   # Journal-specific settings
│   ├── arxiv-config.tex     # arXiv-specific settings
│   └── shared-packages.tex  # Common packages
├── bibliography/
│   ├── refs.bib
│   └── style-adapters/      # Multiple .bst files
├── figures/
│   ├── high-res/           # Journal quality figures
│   └── compressed/         # arXiv size-optimized figures
└── build/                  # Generated PDFs
```

## 🛠️ Quick Start

### Prerequisites
- LaTeX distribution (TeX Live, MiKTeX, etc.)
- Git
- Make (optional, for automated builds)

### Basic Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/saucedo-arxiv-manuscript-system.git
   cd saucedo-arxiv-manuscript-system
   ```

2. **Build journal version:**
   ```bash
   make journal
   ```

3. **Build arXiv version:**
   ```bash
   make arxiv
   ```

4. **Build all versions:**
   ```bash
   make all
   ```

### Manual Compilation

If you prefer manual compilation:

```bash
# Journal version
pdflatex main-journal.tex
bibtex main-journal
pdflatex main-journal.tex
pdflatex main-journal.tex

# arXiv version  
pdflatex main-arxiv.tex
bibtex main-arxiv
pdflatex main-arxiv.tex
pdflatex main-arxiv.tex
```

## 📝 Writing Your Manuscript

### Content Organization
- Write your content in the `content/` directory
- Each section is a separate `.tex` file for modularity
- Use `\input{}` commands to include sections

### Conditional Content
Use conditional commands for target-specific content:

```latex
\journalonly{Content only for journal submission}
\arxivonly{Content only for arXiv preprint}
\draftonly{Content only in draft mode}
```

### Figure Management
- Place high-resolution figures in `figures/high-res/`
- Place compressed figures in `figures/compressed/`
- The system automatically selects the appropriate version

### Bibliography
- Add references to `bibliography/refs.bib`
- The system automatically adapts citation styles for each target

## 🎨 Customization

### Journal Configuration
Edit `config/journal-config.tex` to customize:
- Document class options
- Journal-specific formatting
- Bibliography styles

### arXiv Configuration  
Edit `config/arxiv-config.tex` to customize:
- Page layout and margins
- Hyperlink appearance
- Preprint watermarks

## 🔧 Advanced Features

### Version Control Integration
The system automatically includes git commit information in footers when in draft mode.

### Multi-Format Output
- PDF (primary)
- PostScript (for older systems)
- DVI (for specialized workflows)

### Quality Assurance
- Automatic spell checking integration
- Reference validation
- Figure resolution warnings

## 📚 Documentation

- [Writing Guide](docs/writing-guide.md)
- [Configuration Reference](docs/configuration.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Examples](examples/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with both journal and arXiv modes
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Based on professional academic publishing best practices
- Inspired by the needs of modern scientific communication
- Built for researchers who value both quality and efficiency

## 📬 Contact

Created by Joel Saucedo - [GitHub](https://github.com/yourusername)

---

*Happy publishing! 🎓📄*
