package main

import (
	"errors"
	"os"
	"os/exec"
	"path"
	path2 "path"
	"path/filepath"
	"pgo/pikapi/config"
	"runtime"
	"strings"
)

func init() {
	applicationDir, err := os.UserHomeDir()
	if err != nil {
		panic(err)
	}
	switch runtime.GOOS {
	case "windows":
		// applicationDir = path.Join(applicationDir, "AppData", "Roaming")
		file, err := exec.LookPath(os.Args[0])
		if err != nil {
			panic(err)
		}
		path, err := filepath.Abs(file)
		if err != nil {
			panic(err)
		}
		i := strings.LastIndex(path, "/")
		if i < 0 {
			i = strings.LastIndex(path, "\\")
		}
		if i < 0 {
			panic(errors.New(" can't find \"/\" or \"\\\""))
		}
		applicationDir = path2.Join(path[0:i+1], "data", "pikapi")
	case "darwin":
		applicationDir = path.Join(applicationDir, "Library", "Application Support", "pikapi")
	case "linux":
		applicationDir = path.Join(applicationDir, ".pikapi")
	default:
		panic(errors.New("not supported system"))
	}
	if _, err = os.Stat(applicationDir); err != nil {
		if os.IsNotExist(err) {
			err = os.MkdirAll(applicationDir, os.FileMode(0700))
			if err != nil {
				panic(err)
			}
		} else {
			panic(err)
		}
	}
	config.InitApplication(applicationDir)
}
