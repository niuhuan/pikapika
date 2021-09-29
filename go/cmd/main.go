package main

import (
	"fmt"
	"github.com/go-flutter-desktop/go-flutter"
	"github.com/pkg/errors"
	"image"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"os"
	"path/filepath"
	"pgo/pikapi/database/properties"
	"strconv"
	"strings"
)

// vmArguments may be set by hover at compile-time
var vmArguments string

func main() {
	// DO NOT EDIT, add options in options.go
	mainOptions := []flutter.Option{
		flutter.OptionVMArguments(strings.Split(vmArguments, ";")),
		flutter.WindowIcon(iconProvider),
	}
	// 窗口初始化大小的处理
	widthStr, _ := properties.LoadProperty("window_width", "600")
	heightStr, _ := properties.LoadProperty("window_height", "900")
	width, _ := strconv.Atoi(widthStr)
	height, _ := strconv.Atoi(heightStr)
	if width <= 0 {
		width = 600
	}
	if height <= 0 {
		height = 900
	}
	sizeOption := flutter.WindowInitialDimensions(width, height)
	options = append(options, sizeOption)
	//
	err := flutter.Run(append(options, mainOptions...)...)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func iconProvider() ([]image.Image, error) {
	execPath, err := os.Executable()
	if err != nil {
		return nil, errors.Wrap(err, "failed to resolve executable path")
	}
	execPath, err = filepath.EvalSymlinks(execPath)
	if err != nil {
		return nil, errors.Wrap(err, "failed to eval symlinks for executable path")
	}
	imgFile, err := os.Open(filepath.Join(filepath.Dir(execPath), "assets", "icon.png"))
	if err != nil {
		return nil, errors.Wrap(err, "failed to open assets/icon.png")
	}
	img, _, err := image.Decode(imgFile)
	if err != nil {
		return nil, errors.Wrap(err, "failed to decode image")
	}
	return []image.Image{img}, nil
}
