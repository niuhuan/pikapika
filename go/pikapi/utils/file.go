package utils

import (
	"os"
	"pgo/pikapi/const_value"
)

func Mkdir(dir string) {
	if _, err := os.Stat(dir); err != nil {
		if os.IsNotExist(err) {
			err = os.MkdirAll(dir, const_value.CreateDirMode)
			if err != nil {
				panic(err)
			}
		} else {
			panic(err)
		}
	}
}
