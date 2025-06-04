# Makefile for Saucedo arXiv Manuscript System
# Provides automated building for multiple output formats

# Configuration
MAIN_ARXIV = ../main-arxiv
MAIN_JOURNAL = ../main-journal
MAIN_PREPRINT = ../main-preprint
BUILD_DIR = .
OUTPUT_DIR = output
LATEX = pdflatex
BIBTEX = bibtex

# Create directories if they don't exist
$(shell mkdir -p $(BUILD_DIR) $(OUTPUT_DIR))

# Default target
.PHONY: all
all: arxiv journal preprint

# arXiv version
.PHONY: arxiv
arxiv: $(OUTPUT_DIR)/$(MAIN_ARXIV).pdf

$(OUTPUT_DIR)/$(MAIN_ARXIV).pdf: $(MAIN_ARXIV).tex ../content/*.tex ../config/*.tex ../bibliography/*.bib
	@echo "Building arXiv version..."
	$(LATEX) -output-directory=$(BUILD_DIR) $(MAIN_ARXIV).tex
	cd $(BUILD_DIR) && $(BIBTEX) $(notdir $(MAIN_ARXIV))
	$(LATEX) -output-directory=$(BUILD_DIR) $(MAIN_ARXIV).tex
	$(LATEX) -output-directory=$(BUILD_DIR) $(MAIN_ARXIV).tex
	cp $(BUILD_DIR)/$(notdir $(MAIN_ARXIV)).pdf $(OUTPUT_DIR)/
	@echo "arXiv version built successfully!"

# Journal version
.PHONY: journal
journal: $(OUTPUT_DIR)/$(MAIN_JOURNAL).pdf

$(OUTPUT_DIR)/$(MAIN_JOURNAL).pdf: $(MAIN_JOURNAL).tex ../content/*.tex ../config/*.tex ../bibliography/*.bib
	@echo "Building journal version..."
	$(LATEX) -output-directory=$(BUILD_DIR) $(MAIN_JOURNAL).tex
	cd $(BUILD_DIR) && $(BIBTEX) $(notdir $(MAIN_JOURNAL))
	$(LATEX) -output-directory=$(BUILD_DIR) $(MAIN_JOURNAL).tex
	$(LATEX) -output-directory=$(BUILD_DIR) $(MAIN_JOURNAL).tex
	cp $(BUILD_DIR)/$(notdir $(MAIN_JOURNAL)).pdf $(OUTPUT_DIR)/
	@echo "Journal version built successfully!"

# Preprint version (with draft watermark)
.PHONY: preprint
preprint: $(OUTPUT_DIR)/$(MAIN_PREPRINT).pdf

$(OUTPUT_DIR)/$(MAIN_PREPRINT).pdf: $(MAIN_PREPRINT).tex ../content/*.tex ../config/*.tex ../bibliography/*.bib
	@echo "Building preprint version..."
	$(LATEX) -output-directory=$(BUILD_DIR) $(MAIN_PREPRINT).tex
	cd $(BUILD_DIR) && $(BIBTEX) $(notdir $(MAIN_PREPRINT))
	$(LATEX) -output-directory=$(BUILD_DIR) $(MAIN_PREPRINT).tex
	$(LATEX) -output-directory=$(BUILD_DIR) $(MAIN_PREPRINT).tex
	cp $(BUILD_DIR)/$(notdir $(MAIN_PREPRINT)).pdf $(OUTPUT_DIR)/
	@echo "Preprint version built successfully!"

# Draft versions with line numbers
.PHONY: draft-arxiv
draft-arxiv:
	@echo "Building arXiv draft with line numbers..."
	$(LATEX) -output-directory=$(BUILD_DIR) "\def\draftmode{}\input{$(MAIN_ARXIV).tex}"
	cd $(BUILD_DIR) && $(BIBTEX) $(notdir $(MAIN_ARXIV))
	$(LATEX) -output-directory=$(BUILD_DIR) "\def\draftmode{}\input{$(MAIN_ARXIV).tex}"
	$(LATEX) -output-directory=$(BUILD_DIR) "\def\draftmode{}\input{$(MAIN_ARXIV).tex}"
	cp $(BUILD_DIR)/$(notdir $(MAIN_ARXIV)).pdf $(OUTPUT_DIR)/$(notdir $(MAIN_ARXIV))-draft.pdf
	@echo "arXiv draft built successfully!"

.PHONY: draft-journal
draft-journal:
	@echo "Building journal draft with line numbers..."
	$(LATEX) -output-directory=$(BUILD_DIR) "\def\draftmode{}\input{$(MAIN_JOURNAL).tex}"
	cd $(BUILD_DIR) && $(BIBTEX) $(notdir $(MAIN_JOURNAL))
	$(LATEX) -output-directory=$(BUILD_DIR) "\def\draftmode{}\input{$(MAIN_JOURNAL).tex}"
	$(LATEX) -output-directory=$(BUILD_DIR) "\def\draftmode{}\input{$(MAIN_JOURNAL).tex}"
	cp $(BUILD_DIR)/$(notdir $(MAIN_JOURNAL)).pdf $(OUTPUT_DIR)/$(notdir $(MAIN_JOURNAL))-draft.pdf
	@echo "Journal draft built successfully!"

# Quick build (single pass, for fast iteration)
.PHONY: quick-arxiv
quick-arxiv:
	@echo "Quick building arXiv version..."
	$(LATEX) -output-directory=$(BUILD_DIR) $(MAIN_ARXIV).tex
	cp $(BUILD_DIR)/$(notdir $(MAIN_ARXIV)).pdf $(OUTPUT_DIR)/
	@echo "Quick arXiv build complete!"

.PHONY: quick-journal
quick-journal:
	@echo "Quick building journal version..."
	$(LATEX) -output-directory=$(BUILD_DIR) $(MAIN_JOURNAL).tex
	cp $(BUILD_DIR)/$(notdir $(MAIN_JOURNAL)).pdf $(OUTPUT_DIR)/
	@echo "Quick journal build complete!"

# Clean targets
.PHONY: clean
clean:
	@echo "Cleaning build files..."
	rm -rf $(BUILD_DIR)/*
	@echo "Build directory cleaned!"

.PHONY: clean-all
clean-all: clean
	@echo "Cleaning all output files..."
	rm -rf $(OUTPUT_DIR)/*
	@echo "All files cleaned!"

# Archive for arXiv submission
.PHONY: arxiv-package
arxiv-package: arxiv
	@echo "Creating arXiv submission package..."
	mkdir -p $(OUTPUT_DIR)/arxiv-submission
	cp $(MAIN_ARXIV).tex $(OUTPUT_DIR)/arxiv-submission/
	cp -r content/ $(OUTPUT_DIR)/arxiv-submission/
	cp -r config/ $(OUTPUT_DIR)/arxiv-submission/
	cp -r bibliography/ $(OUTPUT_DIR)/arxiv-submission/
	cp -r figures/compressed/ $(OUTPUT_DIR)/arxiv-submission/figures/
	cp arxiv-preprint.cls $(OUTPUT_DIR)/arxiv-submission/
	cd $(OUTPUT_DIR) && tar -czf arxiv-submission.tar.gz arxiv-submission/
	@echo "arXiv package created: $(OUTPUT_DIR)/arxiv-submission.tar.gz"

# Help target
.PHONY: help
help:
	@echo "Saucedo arXiv Manuscript System - Build Targets:"
	@echo ""
	@echo "  all            - Build all versions (arxiv, journal, preprint)"
	@echo "  arxiv          - Build arXiv optimized version"
	@echo "  journal        - Build journal submission version"
	@echo "  preprint       - Build preprint version with watermark"
	@echo ""
	@echo "  draft-arxiv    - Build arXiv version with line numbers"
	@echo "  draft-journal  - Build journal version with line numbers"
	@echo ""
	@echo "  quick-arxiv    - Quick single-pass arXiv build"
	@echo "  quick-journal  - Quick single-pass journal build"
	@echo ""
	@echo "  arxiv-package  - Create arXiv submission archive"
	@echo ""
	@echo "  clean          - Clean build files"
	@echo "  clean-all      - Clean all generated files"
	@echo "  help           - Show this help message"

# Watch mode (requires entr or inotifywait)
.PHONY: watch-arxiv
watch-arxiv:
	@echo "Watching for changes (arXiv mode)..."
	@while true; do \
		find . -name "*.tex" -o -name "*.bib" | entr -d make quick-arxiv; \
	done

.PHONY: watch-journal
watch-journal:
	@echo "Watching for changes (journal mode)..."
	@while true; do \
		find . -name "*.tex" -o -name "*.bib" | entr -d make quick-journal; \
	done

# =============================================================================
# Testing and Validation
# =============================================================================

.PHONY: test
test:
	@echo "Running comprehensive system test..."
	@chmod +x test.sh
	@./test.sh

.PHONY: validate
validate: test
	@echo "System validation completed"
