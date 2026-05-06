package main

import (
	"bytes"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	jpeg_encoder_decoder "JPEG-transcoder/internal/jpeg-encoder-decoder"
)

type result struct {
	name           string
	originalSize   int64
	compressedSize int64
}

func main() {
	dir30 := flag.String("dir30", "test/jpeg30", "папка с JPEG файлами QF=30")
	dir80 := flag.String("dir80", "test/jpeg80", "папка с JPEG файлами QF=80")
	flag.Parse()

	results30, err := analyzeDir(*dir30)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Ошибка анализа %s: %v\n", *dir30, err)
		os.Exit(1)
	}
	results80, err := analyzeDir(*dir80)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Ошибка анализа %s: %v\n", *dir80, err)
		os.Exit(1)
	}

	printTable(results30, "QF=30")
	fmt.Println()
	printTable(results80, "QF=80")
}

func analyzeDir(dir string) ([]result, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, err
	}
	var results []result
	encoder := jpeg_encoder_decoder.NewJPEGEncoder() // quality не нужен

	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}
		name := entry.Name()
		if !strings.HasSuffix(strings.ToLower(name), ".jpg") {
			continue
		}
		path := filepath.Join(dir, name)

		origData, err := os.ReadFile(path)
		if err != nil {
			return nil, fmt.Errorf("чтение %s: %w", path, err)
		}
		var buf bytes.Buffer
		if err := encoder.Encode(bytes.NewReader(origData), &buf); err != nil {
			return nil, fmt.Errorf("кодирование %s: %w", name, err)
		}
		results = append(results, result{
			name:           name,
			originalSize:   int64(len(origData)),
			compressedSize: int64(buf.Len()),
		})
	}
	return results, nil
}

func printTable(results []result, title string) {
	fmt.Printf("=== %s ===\n", title)
	fmt.Printf("%-30s | %15s | %17s | %6s\n",
		"Image", "Original (bytes)", "Compressed (bytes)", "Ratio")
	fmt.Println(strings.Repeat("-", 30+15+17+6+11))

	var totalOrig, totalComp int64
	for _, r := range results {
		ratio := float64(r.compressedSize) / float64(r.originalSize)
		fmt.Printf("%-30s | %15d | %17d | %6.2f\n",
			r.name, r.originalSize, r.compressedSize, ratio)
		totalOrig += r.originalSize
		totalComp += r.compressedSize
	}
	fmt.Printf("%-30s | %15d | %17d | %6.2f\n",
		"TOTAL", totalOrig, totalComp, float64(totalComp)/float64(totalOrig))
}
