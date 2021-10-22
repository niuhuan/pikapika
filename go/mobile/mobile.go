package mobile

import (
	"pikapi/main/config"
	"pikapi/main/controller"
)

func InitApplication(application string) {
	config.InitApplication(application)
}

func FlatInvoke(method string, params string) (string, error) {
	return controller.FlatInvoke(method, params)
}

func EventNotify(notify EventNotifyHandler) {
	controller.EventNotify = notify.OnNotify
}

type EventNotifyHandler interface {
	OnNotify(message string)
}
