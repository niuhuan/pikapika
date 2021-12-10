package mobile

import (
	"pikapika/pikapika"
	"pikapika/pikapika/config"
)

func InitApplication(application string) {
	config.InitApplication(application)
}

func FlatInvoke(method string, params string) (string, error) {
	return pikapika.FlatInvoke(method, params)
}

func EventNotify(notify EventNotifyHandler) {
	pikapika.EventNotify = notify.OnNotify
}

type EventNotifyHandler interface {
	OnNotify(message string)
}
