package jpeg_encoder_decoder

import "io"

type Decoder interface {
	Decode(from io.Reader, to io.Writer) error
}

type JPEGDecoder struct{}

func NewJPEGDecoder() *JPEGDecoder {
	return &JPEGDecoder{}
}

func (j JPEGDecoder) Decode(from io.Reader, to io.Writer) error {
	return nil
}
