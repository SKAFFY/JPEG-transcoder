package main

import (
	jpeg_encoder_decoder "JPEG-transcoder/internal/jpeg-encoder-decoder"
	"bufio"
	"flag"
	"fmt"
	"os"
)

func main() {
	sourceFilePath := flag.String("f", "", "source file path")
	targetFilePath := flag.String("t", "", "target file path")
	writerBufferSize := flag.Int("buffer-size", 4*1024*1024, "buffer size (default 4MB)")
	quality := flag.Int("q", 30, "quality factor")

	flag.Parse()

	if *sourceFilePath == "" || *targetFilePath == "" {
		flag.Usage()
		os.Exit(1)
	}

	sourceFile, err := os.Open(*sourceFilePath)
	if err != nil {
		fmt.Printf("Error opening source file: %v\n", err)
		return
	}
	defer func() {
		if err := sourceFile.Close(); err != nil {
			fmt.Printf("Error closing source file: %v\n", err)
		}
	}()

	targetFile, err := os.Create(*targetFilePath)
	if err != nil {
		fmt.Printf("Error creating target file: %v\n", err)
		return
	}
	defer func() {
		if err := targetFile.Close(); err != nil {
			fmt.Printf("Error closing target file: %v\n", err)
		}
	}()

	bufTargetFile := bufio.NewWriterSize(targetFile, *writerBufferSize)
	defer func() {
		if err := bufTargetFile.Flush(); err != nil {
			fmt.Printf("Error flushing buffer: %v\n", err)
		}
	}()

	_ = quality

	encoder := jpeg_encoder_decoder.NewJPEGEncoder()

	err = encoder.Encode(sourceFile, bufTargetFile)
	if err != nil {
		fmt.Printf("Error encoding file: %v\n", err)
		return
	}

	return
}
