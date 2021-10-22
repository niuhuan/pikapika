package main

import (
	"errors"
	"github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/go-flutter/plugin"
	"github.com/go-flutter-desktop/plugins/url_launcher"
	"github.com/go-gl/glfw/v3.3/glfw"
	"github.com/miguelpruivo/flutter_file_picker/go"
	"pikapi/main/controller"
	"pikapi/main/database/properties"
	"strconv"
	"sync"
)

var options = []flutter.Option{
	flutter.AddPlugin(&Plugin{}),
	flutter.AddPlugin(&file_picker.FilePickerPlugin{}),
	flutter.AddPlugin(&url_launcher.UrlLauncherPlugin{}),
}

var eventMutex = sync.Mutex{}
var eventSink *plugin.EventSink

type EventHandler struct {
}

func (s *EventHandler) OnListen(arguments interface{}, sink *plugin.EventSink) {
	eventMutex.Lock()
	defer eventMutex.Unlock()
	eventSink = sink
}

func (s *EventHandler) OnCancel(arguments interface{}) {
	eventMutex.Lock()
	defer eventMutex.Unlock()
	eventSink = nil
}

const channelName = "method"

type Plugin struct {
}

func (p *Plugin) InitPlugin(messenger plugin.BinaryMessenger) error {

	channel := plugin.NewMethodChannel(messenger, channelName, plugin.StandardMethodCodec{})

	channel.HandleFunc("flatInvoke", func(arguments interface{}) (interface{}, error) {
		if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
			if method, ok := argumentsMap["method"].(string); ok {
				if params, ok := argumentsMap["params"].(string); ok {
					return controller.FlatInvoke(method, params)
				}
			}
		}
		return nil, errors.New("params error")
	})

	exporting := plugin.NewEventChannel(messenger, "flatEvent", plugin.StandardMethodCodec{})
	exporting.Handle(&EventHandler{})

	controller.EventNotify = func(message string) {
		eventMutex.Lock()
		defer eventMutex.Unlock()
		sink := eventSink
		if sink != nil {
			sink.Success(message)
		}
	}

	return nil // no error
}

func (p *Plugin) InitPluginGLFW(window *glfw.Window) error {
	window.SetSizeCallback(func(w *glfw.Window, width int, height int) {
		properties.SaveProperty("window_width", strconv.Itoa(width))
		properties.SaveProperty("window_height", strconv.Itoa(height))
	})
	return nil
}
