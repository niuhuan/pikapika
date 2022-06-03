package main

import (
	"ci/commons"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
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
	var releaseFileName string
	switch target {
	case "macos":
		releaseFileName = fmt.Sprintf("pikapika-%v-flutter_%v-macos-intel.dmg", version.Code, flutterVersion)
	case "ios":
		releaseFileName = fmt.Sprintf("pikapika-%v-flutter_%v-ios-nosign.ipa", version.Code, flutterVersion)
	case "windows":
		releaseFileName = fmt.Sprintf("pikapika-%v-flutter_%v-windows-x86_64.zip", version.Code, flutterVersion)
	case "linux":
		releaseFileName = fmt.Sprintf("pikapika-%v-flutter_%v-linux-x86_64.AppImage", version.Code, flutterVersion)
	case "android-arm32":
		releaseFileName = fmt.Sprintf("pikapika-%v-flutter_%v-android-arm32.apk", version.Code, flutterVersion)
	case "android-arm64":
		releaseFileName = fmt.Sprintf("pikapika-%v-flutter_%v-android-arm64.apk", version.Code, flutterVersion)
	case "android-x86_64":
		releaseFileName = fmt.Sprintf("pikapika-%v-flutter_%v-android-x86_64.apk", version.Code, flutterVersion)
	}
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
	for _, asset := range release.Assets {
		if asset.Name == releaseFileName {
			println("::set-output name=skip_build::true")
			os.Exit(0)
		}
	}
	print("::set-output name=skip_build::false")
}
