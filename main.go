package main

import (
	"bufio"
	"encoding/csv"
	"io"
	"os"

	"go.uber.org/zap"
	"golang.org/x/text/encoding/unicode"
	"golang.org/x/text/transform"
)

func main() {
	inFilename := "nicoime_msime.txt"
	inFp, err := os.Open(inFilename)
	if err != nil {
		logger.Fatal("no such file", zap.String("filename", inFilename), zap.Error(err))
	}

	outFilename := "mac_" + inFilename
	outFp, err := os.Create(outFilename)
	if err != nil {
		logger.Fatal("failed to create file", zap.String("filename", outFilename), zap.Error(err))
	}

	reader := NewMSIMEDictionaryReader(inFp)
	writer := NewMacDictionaryWriter(outFp)
	for {
		entry, err := reader.Read()
		if err == io.EOF {
			break
		}

		if err != nil {
			logger.Warn("invalid data", zap.Error(err))
			continue
		}

		if err = writer.Write(entry); err != nil {
			logger.Fatal("failed to write entry", zap.Strings("entry", entry))
		}
	}

	if err = inFp.Close(); err != nil {
		logger.Fatal("failed to close file", zap.String("filename", inFilename), zap.Error(err))
	}

	if err = outFp.Close(); err != nil {
		logger.Fatal("failed to close file", zap.String("filename", outFilename), zap.Error(err))
	}
}

func NewUTF16LECSVReader(r io.Reader) *csv.Reader {
	reader := bufio.NewReader(r)
	decoder := unicode.UTF16(unicode.LittleEndian, unicode.UseBOM).NewDecoder()

	return csv.NewReader(transform.NewReader(reader, decoder))
}

func NewMSIMEDictionaryReader(r io.Reader) *csv.Reader {
	reader := NewUTF16LECSVReader(r)
	reader.Comma = '\t'
	reader.Comment = '!'
	reader.FieldsPerRecord = 3
	return reader
}

func NewMacDictionaryWriter(w io.Writer) *csv.Writer {
	return csv.NewWriter(w)
}
