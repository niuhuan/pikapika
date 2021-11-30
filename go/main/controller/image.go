package controller

import (
	"bytes"
	"context"
	"errors"
	_ "golang.org/x/image/webp"
	"image"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"io/ioutil"
	"net"
	"net/http"
	"pikapika/main/database/comic_center"
	"sync"
	"time"
)

var mutexCounter = -1
var busMutex *sync.Mutex
var subMutexes []*sync.Mutex
var imageHttpClient *http.Client

// imageSwitchAddress
// 图片的分流直接使用 switchAddressPattern 可以正常使用
// 通过ping发现图片的分流地址与ip一致
// 这里为了域名与官方一致改为域名分流
var imageSwitchAddresses = map[int]string{
	1: "https://storage.wika" + "wika.xyz",
	2: "https://s2.pica" + "comic.com",
	3: "https://s3.pica" + "comic.com",
}

var imageSwitchAddress int

func init() {
	busMutex = &sync.Mutex{}
	for i := 0; i < 5; i++ {
		subMutexes = append(subMutexes, &sync.Mutex{})
	}
	imageHttpClient = &http.Client{
		Transport: &http.Transport{
			TLSHandshakeTimeout:   time.Second * 10,
			ExpectContinueTimeout: time.Second * 10,
			ResponseHeaderTimeout: time.Second * 10,
			IdleConnTimeout:       time.Second * 10,
			DialContext: func(ctx context.Context, network, addr string) (net.Conn, error) {
				return dialer.DialContext(ctx, network, addr)
			},
		},
	}
}

// takeMutex 下载图片获取一个锁, 这样只能同时下载5张图片
func takeMutex() *sync.Mutex {
	busMutex.Lock()
	defer busMutex.Unlock()
	mutexCounter = (mutexCounter + 1) % len(subMutexes)
	return subMutexes[mutexCounter]
}

func decodeInfoFromBuff(buff []byte) (image.Image, string, error) {
	buffer := bytes.NewBuffer(buff)
	return image.Decode(buffer)
}

func decodeFromFile(path string) ([]byte, image.Image, string, error) {
	b, e := ioutil.ReadFile(path)
	if e != nil {
		return nil, nil, "", e
	}
	i, f, e := decodeInfoFromBuff(b)
	if e != nil {
		return nil, nil, "", e
	}
	return b, i, f, e
}

// 下载图片并decode
func decodeFromUrl(fileServer string, path string) ([]byte, image.Image, string, error) {
	useClient := imageHttpClient
	if imageSwitchAddress == -1 {
		useClient = &client.Client
	}
	if server, ok := imageSwitchAddresses[imageSwitchAddress]; ok {
		fileServer = server
	}
	m := takeMutex()
	m.Lock()
	defer m.Unlock()
	request, err := http.NewRequest("GET", fileServer+"/static/"+path, nil)
	if err != nil {
		return nil, nil, "", err
	}
	response, err := useClient.Do(request)
	if err != nil {
		return nil, nil, "", err
	}
	defer response.Body.Close()
	if response.StatusCode != 200 {
		return nil, nil, "", errors.New("code is not 200")
	}
	buff, err := ioutil.ReadAll(response.Body)
	if err != nil {
		return nil, nil, "", err
	}
	img, format, err := decodeInfoFromBuff(buff)
	if err != nil {
		return nil, nil, "", err
	}
	return buff, img, format, err
}

// decodeFromCache 仅下载使用
func decodeFromCache(fileServer string, path string) ([]byte, image.Image, string, error) {
	cache := comic_center.FindRemoteImage(fileServer, path)
	if cache != nil {
		buff, err := ioutil.ReadFile(remotePath(cache.LocalPath))
		if err != nil {
			return nil, nil, "", err
		}
		img, format, err := decodeInfoFromBuff(buff)
		if err != nil {
			return nil, nil, "", err
		}
		return buff, img, format, err
	}
	return nil, nil, "", errors.New("not found")
}
