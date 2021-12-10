package pikapika

import (
	"encoding/json"
	"pikapika/pikapika/database/comic_center"
	"pikapika/pikapika/database/network_cache"
	"time"
)

// EventNotify EventChannel 总线
var EventNotify func(message string)

// 所有的EventChannel都是从这里发出, 格式为json, function代表了是什么事件, content是消息的内容
// 消息传到前端后由前端调度分发
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

// 发送下载的事件
func downloadComicEventSend(comicDownload *comic_center.ComicDownload) {
	buff, err := json.Marshal(comicDownload)
	if err == nil {
		onEvent("DOWNLOAD", string(buff))
	} else {
		print("SEND ERR?")
	}
}

// 发送导出的事件
func notifyExport(str string) {
	onEvent("EXPORT", str)
}

// 缓存接口
func cacheable(key string, expire time.Duration, reload func() (interface{}, error)) (string, error) {
	// CACHE
	cache := network_cache.LoadCache(key, expire)
	if cache != "" {
		return cache, nil
	}
	// obj
	obj, err := reload()
	if err != nil {
		return "", err
	}
	buff, err := json.Marshal(obj)
	// push to cache
	if err != nil {
		return "", err
	}
	// return
	cache = string(buff)
	network_cache.SaveCache(key, cache)
	return cache, nil
}

// 将interface序列化成字符串, 方便与flutter通信
func serialize(point interface{}, err error) (string, error) {
	if err != nil {
		return "", err
	}
	buff, err := json.Marshal(point)
	return string(buff), nil
}
