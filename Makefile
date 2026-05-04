PARSER_URL = https://eugeniy-belyaev.narod.ru/InfTheory/parser.7z
JPEG_URL   = https://eugeniy-belyaev.narod.ru/InfTheory/jpeg-source.7z

PARSER_DIR = third_party/parser
JPEG_DIR   = third_party/jpeg-source
BIN_DIR    = bin

.PHONY: all clean setup build-parser build-jpeg

all: setup build-parser build-jpeg

setup:
	mkdir -p $(PARSER_DIR) $(JPEG_DIR) $(BIN_DIR)

# Распаковка parser.7z
$(PARSER_DIR)/.extracted:
	wget -q --show-progress -O /tmp/parser.7z $(PARSER_URL)
	mkdir -p /tmp/parser_extract
	7z x /tmp/parser.7z -o/tmp/parser_extract -y
	@if [ $$(ls -1 /tmp/parser_extract | wc -l) -eq 1 ] && [ -d /tmp/parser_extract/*/ ]; then \
		cp -r /tmp/parser_extract/*/* $(PARSER_DIR)/; \
	else \
		cp -r /tmp/parser_extract/* $(PARSER_DIR)/; \
	fi
	rm -rf /tmp/parser_extract
	touch $(PARSER_DIR)/.extracted

# Распаковка jpeg-source.7z
$(JPEG_DIR)/.extracted:
	wget -q --show-progress -O /tmp/jpeg.7z $(JPEG_URL)
	mkdir -p /tmp/jpeg_extract
	7z x /tmp/jpeg.7z -o/tmp/jpeg_extract -y
	@if [ $$(ls -1 /tmp/jpeg_extract | wc -l) -eq 1 ] && [ -d /tmp/jpeg_extract/*/ ]; then \
		cp -r /tmp/jpeg_extract/*/* $(JPEG_DIR)/; \
	else \
		cp -r /tmp/jpeg_extract/* $(JPEG_DIR)/; \
	fi
	rm -rf /tmp/jpeg_extract
	touch $(JPEG_DIR)/.extracted

# Сборка parser (jpegenc и jpegdec)
build-parser: $(PARSER_DIR)/.extracted
	cd $(PARSER_DIR) && g++ -O2 jpegenc.cpp -o jpegenc
	cd $(PARSER_DIR) && g++ -O2 jpegdec.cpp -o jpegdec
	cp $(PARSER_DIR)/jpegenc $(BIN_DIR)/parser_jpegenc
	cp $(PARSER_DIR)/jpegdec $(BIN_DIR)/parser_jpegdec

# Сборка jpeg-source (jpegenc и jpegdec)
build-jpeg: $(JPEG_DIR)/.extracted
	cd $(JPEG_DIR) && g++ -O2 jpegenc.cpp -o jpegenc
	cd $(JPEG_DIR) && g++ -O2 jpegdec.cpp -o jpegdec
	cp $(JPEG_DIR)/jpegenc $(BIN_DIR)/jpsrc_jpegenc
	cp $(JPEG_DIR)/jpegdec $(BIN_DIR)/jpsrc_jpegdec

clean:
	rm -rf $(PARSER_DIR) $(JPEG_DIR) $(BIN_DIR)
	rm -f /tmp/parser.7z /tmp/jpeg.7z