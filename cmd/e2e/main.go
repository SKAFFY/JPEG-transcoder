package main

import (
	"bytes"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"

	jpeg_encoder_decoder "JPEG-transcoder/internal/jpeg-encoder-decoder"
)

func main() {
	dir30 := flag.String("dir30", "test/jpeg30", "папка с JPEG файлами QF=30")
	dir80 := flag.String("dir80", "test/jpeg80", "папка с JPEG файлами QF=80")
	keepTemp := flag.Bool("keep", false, "не удалять временные файлы")
	flag.Parse()

	encoder := jpeg_encoder_decoder.NewJPEGEncoder()
	decoder := jpeg_encoder_decoder.NewJPEGDecoder()

	// Собираем все JPEG из обеих папок
	var files []string
	for _, dir := range []string{*dir30, *dir80} {
		matches, err := filepath.Glob(filepath.Join(dir, "*.jpg"))
		if err != nil {
			fmt.Fprintf(os.Stderr, "ошибка поиска в %s: %v\n", dir, err)
			os.Exit(1)
		}
		files = append(files, matches...)
	}

	if len(files) == 0 {
		fmt.Fprintln(os.Stderr, "нет JPEG-файлов для проверки")
		os.Exit(1)
	}

	allOk := true
	for _, srcPath := range files {
		fmt.Printf("Проверяю %s... ", srcPath)

		// Читаем исходный файл
		origData, err := os.ReadFile(srcPath)
		if err != nil {
			fmt.Printf("ошибка чтения: %v\n", err)
			allOk = false
			continue
		}

		// Временный файл для сжатых данных
		encFile, err := os.CreateTemp("", "e2e_enc_*.bin")
		if err != nil {
			fmt.Printf("ошибка temp: %v\n", err)
			allOk = false
			continue
		}
		encPath := encFile.Name()
		if !*keepTemp {
			defer os.Remove(encPath)
		}
		defer encFile.Close()

		// Кодирование
		if err := encoder.Encode(bytes.NewReader(origData), encFile); err != nil {
			fmt.Printf("ошибка кодирования: %v\n", err)
			allOk = false
			continue
		}

		// Временный файл для восстановленного JPEG
		decFile, err := os.CreateTemp("", "e2e_dec_*.jpg")
		if err != nil {
			fmt.Printf("ошибка temp: %v\n", err)
			allOk = false
			continue
		}
		decPath := decFile.Name()
		if !*keepTemp {
			defer os.Remove(decPath)
		}
		defer decFile.Close()

		// Декодирование
		if _, err := encFile.Seek(0, io.SeekStart); err != nil {
			fmt.Printf("ошибка seek: %v\n", err)
			allOk = false
			continue
		}
		if err := decoder.Decode(encFile, decFile); err != nil {
			fmt.Printf("ошибка декодирования: %v\n", err)
			allOk = false
			continue
		}

		// Сравнение
		decData, err := os.ReadFile(decPath)
		if err != nil {
			fmt.Printf("ошибка чтения декодированного: %v\n", err)
			allOk = false
			continue
		}

		if bytes.Equal(origData, decData) {
			fmt.Println("✅ OK")
		} else {
			fmt.Println("❌ не совпадает (размеры: исходный", len(origData), "декодированный", len(decData), ")")
			allOk = false
		}
	}

	if allOk {
		fmt.Println("\n✅ Все тесты пройдены: кодирование+декодирование восстанавливают исходные файлы бит в бит.")
		os.Exit(0)
	} else {
		fmt.Println("\n❌ Некоторые тесты не удались.")
		os.Exit(1)
	}

	return
}
