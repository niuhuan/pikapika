package main

import (
	"github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/plugins/url_launcher"
	"github.com/miguelpruivo/flutter_file_picker/go"
	"pgo/cmd/plugin/pikapi"
)

var options = []flutter.Option{
	flutter.AddPlugin(&pikapi.Plugin{}),
	flutter.AddPlugin(&file_picker.FilePickerPlugin{}),
	flutter.AddPlugin(&url_launcher.UrlLauncherPlugin{}),
}
