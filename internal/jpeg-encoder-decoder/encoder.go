package jpeg_encoder_decoder

import (
	"io"
)

type Encoder interface {
	Encode(from io.Reader, to io.Writer) error
}

type JPEGEncoder struct{}

func NewJPEGEncoder() *JPEGEncoder {
	return &JPEGEncoder{}
}

func (j JPEGEncoder) Encode(from io.Reader, to io.Writer) error {
	return nil
}
