package utils

import (
	"errors"
	"os"
	"strings"
)

func Mkdir(dir string) {
	if _, err := os.Stat(dir); err != nil {
		if os.IsNotExist(err) {
			err = os.MkdirAll(dir, CreateDirMode)
			if err != nil {
				panic(err)
			}
		} else {
			panic(err)
		}
	}
}

func ReasonableFileName(title string) string {
	title = strings.ReplaceAll(title, "\\", "_")
	title = strings.ReplaceAll(title, "/", "_")
	title = strings.ReplaceAll(title, "*", "_")
	title = strings.ReplaceAll(title, "?", "_")
	title = strings.ReplaceAll(title, "<", "_")
	title = strings.ReplaceAll(title, ">", "_")
	title = strings.ReplaceAll(title, "|", "_")
	return title
}

func Exists(name string) (bool, error) {
	_, err := os.Stat(name)
	if err == nil {
		return true, nil
	}
	if errors.Is(err, os.ErrNotExist) {
		return false, nil
	}
	return false, err
}