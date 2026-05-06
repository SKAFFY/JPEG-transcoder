package jpeg_encoder_decoder

import (
	"bytes"
	"embed"
	"path/filepath"
	"testing"
)

//go:embed test-data/*.jpg
var testDataFS embed.FS

// TestEncodeDecodeIdentity проверяет идентичность после цикла кодирования/декодирования
// с использованием встроенных тестовых изображений.
func TestEncodeDecodeIdentity(t *testing.T) {
	entries, err := testDataFS.ReadDir("test-data")
	if err != nil {
		t.Fatalf("не удалось прочитать встроенную папку test-data: %v", err)
	}

	var jpegFiles []string
	for _, entry := range entries {
		if !entry.IsDir() && filepath.Ext(entry.Name()) == ".jpg" {
			jpegFiles = append(jpegFiles, entry.Name())
		}
	}

	if len(jpegFiles) == 0 {
		t.Fatal("во встроенной папке test-data нет JPEG-файлов")
	}

	encoder := NewJPEGEncoder()
	decoder := NewJPEGDecoder()

	for _, fileName := range jpegFiles {
		t.Run(fileName, func(t *testing.T) {
			// Читаем встроенный файл
			origData, err := testDataFS.ReadFile("test-data/" + fileName)
			if err != nil {
				t.Fatalf("ошибка чтения встроенного файла %s: %v", fileName, err)
			}

			// Кодируем
			encBuf := &bytes.Buffer{}
			if err := encoder.Encode(bytes.NewReader(origData), encBuf); err != nil {
				t.Fatalf("ошибка кодирования: %v", err)
			}
			compressedSize := encBuf.Len()

			// Декодируем
			decBuf := &bytes.Buffer{}
			if err := decoder.Decode(bytes.NewReader(encBuf.Bytes()), decBuf); err != nil {
				t.Fatalf("ошибка декодирования: %v", err)
			}

			// Сравниваем побайтово
			if !bytes.Equal(origData, decBuf.Bytes()) {
				t.Fatalf("восстановленный файл не совпадает с исходным")
			}

			t.Logf("✓ %s: исходный %d байт → сжатый %d байт (коэффициент %.2f)",
				fileName, len(origData), compressedSize, float64(compressedSize)/float64(len(origData)))
		})
	}
}
