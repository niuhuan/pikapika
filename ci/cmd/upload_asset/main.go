package main

import (
	"ci/commons"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"path"
)

func main() {
	// get ghToken
	ghToken := os.Getenv("GH_TOKEN")
	if ghToken == "" {
		println("Env ${GH_TOKEN} is not set")
		os.Exit(1)
	}
	// get version
	version := commons.LoadVersion()
	// get target
	target := os.Getenv("TARGET")
	if target == "" {
		println("Env ${TARGET} is not set")
		os.Exit(1)
	}
	// get target
	flutterVersion := os.Getenv("flutter_version")
	if target == "" {
		println("Env ${flutter_version} is not set")
		os.Exit(1)
	}
	//
	var releaseFilePath string
	var releaseFileName string
	var contentType string
	var contentLength int64
	switch target {
	case "macos":
		releaseFilePath = "build/build.dmg"
		releaseFileName = fmt.Sprintf("pikapika-%v-flutter_%v-macos-intel.dmg", version.Code, flutterVersion)
		contentType = "application/octet-stream"
	case "ios":
		releaseFilePath = "build/nosign.ipa"
		releaseFileName = fmt.Sprintf("pikapika-%v-flutter_%v-ios-nosign.ipa", version.Code, flutterVersion)
		contentType = "application/octet-stream"
	case "windows":
		releaseFilePath = "build/build.zip"
		releaseFileName = fmt.Sprintf("pikapika-%v-flutter_%v-windows-x86_64.zip", version.Code, flutterVersion)
		contentType = "application/octet-stream"
	case "linux":
		releaseFilePath = "build/build.AppImage"
		releaseFileName = fmt.Sprintf("pikapika-%v-flutter_%v-linux-x86_64.AppImage", version.Code, flutterVersion)
		contentType = "application/octet-stream"
	case "android-arm32":
		releaseFilePath = "build/app/outputs/flutter-apk/app-release.apk"
		releaseFileName = fmt.Sprintf("pikapika-%v-flutter_%v-android-arm32.apk", version.Code, flutterVersion)
		contentType = "application/octet-stream"
	case "android-arm64":
		releaseFilePath = "build/app/outputs/flutter-apk/app-release.apk"
		releaseFileName = fmt.Sprintf("pikapika-%v-flutter_%v-android-arm64.apk", version.Code, flutterVersion)
		contentType = "application/octet-stream"
	case "android-x86_64":
		releaseFilePath = "build/app/outputs/flutter-apk/app-release.apk"
		releaseFileName = fmt.Sprintf("pikapika-%v-flutter_%v-android-x86_64.apk", version.Code, flutterVersion)
		contentType = "application/octet-stream"
	}
	releaseFilePath = path.Join("..", releaseFilePath)
	info, err := os.Stat(releaseFilePath)
	if err != nil {
		panic(err)
	}
	contentLength = info.Size()
	// get version
	getReleaseRequest, err := http.NewRequest(
		"GET",
		fmt.Sprintf("https://api.github.com/repos/%v/%v/releases/tags/%v", commons.Owner, commons.Repo, version.Code),
		nil,
	)
	if err != nil {
		panic(err)
	}
	getReleaseRequest.Header.Set("User-Agent", commons.Ua)
	getReleaseRequest.Header.Set("Authorization", "token "+ghToken)
	getReleaseResponse, err := http.DefaultClient.Do(getReleaseRequest)
	if err != nil {
		panic(err)
	}
	defer getReleaseResponse.Body.Close()
	if getReleaseResponse.StatusCode == 404 {
		panic("NOT FOUND RELEASE")
	}
	buff, err := ioutil.ReadAll(getReleaseResponse.Body)
	if err != nil {
		panic(err)
	}
	var release commons.Release
	err = json.Unmarshal(buff, &release)
	if err != nil {
		println(string(buff))
		panic(err)
	}
	file, err := os.Open(releaseFilePath)
	if err != nil {
		panic(err)
	}
	defer file.Close()
	uploadUrl := fmt.Sprintf("https://uploads.github.com/repos/%v/%v/releases/%v/assets?name=%v", commons.Owner, commons.Repo, release.Id, releaseFileName)
	uploadRequest, err := http.NewRequest("POST", uploadUrl, file)
	if err != nil {
		panic(err)
	}
	uploadRequest.Header.Set("User-Agent", commons.Ua)
	uploadRequest.Header.Set("Authorization", "token "+ghToken)
	uploadRequest.Header.Set("Content-Type", contentType)
	uploadRequest.ContentLength = contentLength
	uploadResponse, err := http.DefaultClient.Do(uploadRequest)
	if err != nil {
		panic(err)
	}
	if uploadResponse.StatusCode != 201 {
		buff, err = ioutil.ReadAll(uploadResponse.Body)
		if err != nil {
			panic(err)
		}
		println(string(buff))
		panic("NOT 201")
	}
}
