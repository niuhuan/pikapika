package controller

import (
	"encoding/json"
	"pgo/pikapi/database/comic_center"
)

var EventNotify func(message string)

func onEvent(function string, content string) {
	event := EventNotify
	if event != nil {
		message := map[string]string{
			"function": function,
			"content":  content,
		}
		buff, err := json.Marshal(message)
		if err == nil {
			event(string(buff))
		} else {
			print("SEND ERR?")
		}
	}
}

func downloadComicEventSend(comicDownload *comic_center.ComicDownload) {
	buff, err := json.Marshal(comicDownload)
	if err == nil {
		onEvent("DOWNLOAD", string(buff))
	} else {
		print("SEND ERR?")
	}
}

func notifyExport(str string) {
	onEvent("EXPORT", str)
}

func serialize(point interface{}, err error) (string, error) {
	if err != nil {
		return "", err
	}
	buff, err := json.Marshal(point)
	return string(buff), nil
}
