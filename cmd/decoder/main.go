package main

import (
	"flag"
	"os"
)

func main() {
	sourceFilePath := flag.String("f", "", "source file path")
	targetFilePath := flag.String("t", "", "target file path")
	quality := flag.Int("q", 30, "quality factor (default 30)")

	flag.Parse()

	if *sourceFilePath == "" || *targetFilePath == "" {
		flag.Usage()
		os.Exit(1)
	}

	_ = quality
}
