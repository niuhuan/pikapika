package utils

import (
	"os"
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
