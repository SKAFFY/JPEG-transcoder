# ============================================================================
# Go parameters
# ============================================================================
GOCMD      = go
GOBUILD    = $(GOCMD) build
GORUN      = $(GOCMD) run
GOTEST     = $(GOCMD) test

# ============================================================================
# Go binary names
# ============================================================================
ENCODER_BIN     = jpeg_encoder
DECODER_BIN     = jpeg_decoder
E2E_BIN         = jpeg_e2e_test
ANALYSIS_BIN    = jpeg_analysis

# Paths to Go main packages
ENCODER_MAIN    = ./cmd/encoder
DECODER_MAIN    = ./cmd/decoder
E2E_MAIN        = ./cmd/e2e
ANALYSIS_MAIN   = ./cmd/analysis

# ============================================================================
# Directories
# ============================================================================
BIN_DIR         = ./bin
PARSER_DIR      = ./third_party/parser
JPEG_DIR        = ./third_party/jpeg-source
TEST30_DIR      = ./test/jpeg30
TEST80_DIR      = ./test/jpeg80
REPORTS_DIR     = ./test/reports

# ============================================================================
# URLs for downloads
# ============================================================================
PARSER_URL      = https://eugeniy-belyaev.narod.ru/InfTheory/parser.7z
JPEG_URL        = https://eugeniy-belyaev.narod.ru/InfTheory/jpeg-source.7z
DATASET30_URL   = https://eugeniy-belyaev.narod.ru/InfTheory/jpeg30.7z
DATASET80_URL   = https://eugeniy-belyaev.narod.ru/InfTheory/jpeg80.7z

# Marker files for extraction
PARSER_EXTRACTED = $(PARSER_DIR)/.extracted
JPEG_EXTRACTED   = $(JPEG_DIR)/.extracted
DATASET30_EXTRACTED = $(TEST30_DIR)/.extracted
DATASET80_EXTRACTED = $(TEST80_DIR)/.extracted

# ============================================================================
# Default target
# ============================================================================
all: setup build-parser build-jpeg setup-datasets build-go

# ============================================================================
# Create directories
# ============================================================================
setup:
	mkdir -p $(PARSER_DIR) $(JPEG_DIR) $(BIN_DIR) $(TEST30_DIR) $(TEST80_DIR) $(REPORTS_DIR)   # добавлен REPORTS_DIR

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(REPORTS_DIR):                           # ДОБАВЛЕНО
	mkdir -p $(REPORTS_DIR)

# ============================================================================
# Download and extract parser.7z
# ============================================================================
$(PARSER_EXTRACTED): $(PARSER_DIR)
	wget -q --show-progress -O /tmp/parser.7z $(PARSER_URL)
	mkdir -p /tmp/parser_extract
	7z x /tmp/parser.7z -o/tmp/parser_extract -y
	@if [ $$(ls -1 /tmp/parser_extract | wc -l) -eq 1 ] && [ -d /tmp/parser_extract/*/ ]; then \
		cp -r /tmp/parser_extract/*/* $(PARSER_DIR)/; \
	else \
		cp -r /tmp/parser_extract/* $(PARSER_DIR)/; \
	fi
	rm -rf /tmp/parser_extract
	rm -f /tmp/parser.7z
	touch $(PARSER_EXTRACTED)

# ============================================================================
# Download and extract jpeg-source.7z
# ============================================================================
$(JPEG_EXTRACTED): $(JPEG_DIR)
	wget -q --show-progress -O /tmp/jpeg.7z $(JPEG_URL)
	mkdir -p /tmp/jpeg_extract
	7z x /tmp/jpeg.7z -o/tmp/jpeg_extract -y
	@if [ $$(ls -1 /tmp/jpeg_extract | wc -l) -eq 1 ] && [ -d /tmp/jpeg_extract/*/ ]; then \
		cp -r /tmp/jpeg_extract/*/* $(JPEG_DIR)/; \
	else \
		cp -r /tmp/jpeg_extract/* $(JPEG_DIR)/; \
	fi
	rm -rf /tmp/jpeg_extract
	rm -f /tmp/jpeg.7z
	touch $(JPEG_EXTRACTED)

# ============================================================================
# Download and extract JPEG30 dataset
# ============================================================================
$(DATASET30_EXTRACTED): $(TEST30_DIR)
	wget -q --show-progress -O /tmp/jpeg30.7z $(DATASET30_URL)
	mkdir -p /tmp/jpeg30_extract
	7z x /tmp/jpeg30.7z -o/tmp/jpeg30_extract -y
	@if [ $$(ls -1 /tmp/jpeg30_extract | wc -l) -eq 1 ] && [ -d /tmp/jpeg30_extract/*/ ]; then \
		cp -r /tmp/jpeg30_extract/*/* $(TEST30_DIR)/; \
	else \
		cp -r /tmp/jpeg30_extract/* $(TEST30_DIR)/; \
	fi
	rm -rf /tmp/jpeg30_extract
	rm -f /tmp/jpeg30.7z
	touch $(DATASET30_EXTRACTED)

# ============================================================================
# Download and extract JPEG80 dataset
# ============================================================================
$(DATASET80_EXTRACTED): $(TEST80_DIR)
	wget -q --show-progress -O /tmp/jpeg80.7z $(DATASET80_URL)
	mkdir -p /tmp/jpeg80_extract
	7z x /tmp/jpeg80.7z -o/tmp/jpeg80_extract -y
	@if [ $$(ls -1 /tmp/jpeg80_extract | wc -l) -eq 1 ] && [ -d /tmp/jpeg80_extract/*/ ]; then \
		cp -r /tmp/jpeg80_extract/*/* $(TEST80_DIR)/; \
	else \
		cp -r /tmp/jpeg80_extract/* $(TEST80_DIR)/; \
	fi
	rm -rf /tmp/jpeg80_extract
	rm -f /tmp/jpeg80.7z
	touch $(DATASET80_EXTRACTED)

# Convenience target for datasets
setup-datasets: $(DATASET30_EXTRACTED) $(DATASET80_EXTRACTED)

# Ensure datasets are downloaded and extracted (idempotent)   # ДОБАВЛЕНО
ensure-datasets: $(DATASET30_EXTRACTED) $(DATASET80_EXTRACTED)

# ============================================================================
# Build C++ parser executables
# ============================================================================
build-parser: $(PARSER_EXTRACTED)
	cd $(PARSER_DIR) && g++ -O2 jpegenc.cpp -o jpegenc
	cd $(PARSER_DIR) && g++ -O2 jpegdec.cpp -o jpegdec
	cp $(PARSER_DIR)/jpegenc $(BIN_DIR)/parser_jpegenc
	cp $(PARSER_DIR)/jpegdec $(BIN_DIR)/parser_jpegdec

# ============================================================================
# Build C++ reference jpeg executables
# ============================================================================
build-jpeg: $(JPEG_EXTRACTED)
	cd $(JPEG_DIR) && g++ -O2 jpegenc.cpp -o jpegenc
	cd $(JPEG_DIR) && g++ -O2 jpegdec.cpp -o jpegdec
	cp $(JPEG_DIR)/jpegenc $(BIN_DIR)/jpsrc_jpegenc
	cp $(JPEG_DIR)/jpegdec $(BIN_DIR)/jpsrc_jpegdec

# ============================================================================
# Build Go binaries (native OS)
# ============================================================================
build-go: $(BIN_DIR) $(BIN_DIR)/$(ENCODER_BIN) $(BIN_DIR)/$(DECODER_BIN) $(BIN_DIR)/$(E2E_BIN) $(BIN_DIR)/$(ANALYSIS_BIN)

$(BIN_DIR)/$(ENCODER_BIN): $(ENCODER_MAIN)
	$(GOBUILD) -o $(BIN_DIR)/$(ENCODER_BIN) $(ENCODER_MAIN)

$(BIN_DIR)/$(DECODER_BIN): $(DECODER_MAIN)
	$(GOBUILD) -o $(BIN_DIR)/$(DECODER_BIN) $(DECODER_MAIN)

$(BIN_DIR)/$(E2E_BIN): $(E2E_MAIN)
	$(GOBUILD) -o $(BIN_DIR)/$(E2E_BIN) $(E2E_MAIN)

$(BIN_DIR)/$(ANALYSIS_BIN): $(ANALYSIS_MAIN)
	$(GOBUILD) -o $(BIN_DIR)/$(ANALYSIS_BIN) $(ANALYSIS_MAIN)

# ============================================================================
# Cross‑compile for Windows 10 (64-bit)
# ============================================================================
build-windows:
	mkdir -p $(BIN_DIR)/windows
	GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(BIN_DIR)/windows/$(ENCODER_BIN).exe $(ENCODER_MAIN)
	GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(BIN_DIR)/windows/$(DECODER_BIN).exe $(DECODER_MAIN)
	GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(BIN_DIR)/windows/$(E2E_BIN).exe $(E2E_MAIN)
	GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(BIN_DIR)/windows/$(ANALYSIS_BIN).exe $(ANALYSIS_MAIN)

# ============================================================================
# E2E test targets (uses Go e2e binary)
# ============================================================================
# Run e2e with compiled binaries (default dataset paths)
test-e2e: build-go ensure-datasets   # изменено setup-datasets -> ensure-datasets
	$(BIN_DIR)/$(E2E_BIN) -dir30=$(TEST30_DIR) -dir80=$(TEST80_DIR)

# Run e2e with custom directories (example: make test-e2e-custom DIR30=./my30 DIR80=./my80)
test-e2e-custom: build-go
	$(BIN_DIR)/$(E2E_BIN) -dir30=$(DIR30) -dir80=$(DIR80)

# Run e2e without compilation (go run, good for development) – uses default datasets
run-e2e: ensure-datasets
	$(GORUN) $(E2E_MAIN) -dir30=$(TEST30_DIR) -dir80=$(TEST80_DIR)

# ============================================================================
# Analysis targets (compression ratio and total size)
# ============================================================================
analysis: ensure-datasets $(BIN_DIR)/$(ANALYSIS_BIN)
	$(BIN_DIR)/$(ANALYSIS_BIN) -dir30=$(TEST30_DIR) -dir80=$(TEST80_DIR)

analysis-save: ensure-datasets $(REPORTS_DIR) $(BIN_DIR)/$(ANALYSIS_BIN)
	$(BIN_DIR)/$(ANALYSIS_BIN) -dir30=$(TEST30_DIR) -dir80=$(TEST80_DIR) > $(REPORTS_DIR)/analysis_$(shell date +%Y%m%d_%H%M%S).txt

# ============================================================================
# Unit tests
# ============================================================================
test:
	$(GOTEST) ./...

# ============================================================================
# Cleanup
# ============================================================================
clean:
	rm -rf $(BIN_DIR)

clean-cpp:
	rm -rf $(PARSER_DIR) $(JPEG_DIR)

clean-datasets:
	rm -rf $(TEST30_DIR) $(TEST80_DIR)

clean-reports:
	rm -rf $(REPORTS_DIR)

clean-all: clean clean-cpp clean-datasets clean-reports
	rm -f /tmp/parser.7z /tmp/jpeg.7z /tmp/jpeg30.7z /tmp/jpeg80.7z

.PHONY: all setup build-parser build-jpeg build-go build-windows \
        setup-datasets ensure-datasets test-e2e test-e2e-custom run-e2e \
        analysis analysis-save test \
        clean clean-cpp clean-datasets clean-reports clean-all