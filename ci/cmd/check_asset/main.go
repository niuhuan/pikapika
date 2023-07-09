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
	// get TARGET
	target := os.Getenv("TARGET")
	if target == "" {
		println("Env ${TARGET} is not set")
		os.Exit(1)
	}
	// get FLUTTER_VERSION
	flutterVersion := os.Getenv("FLUTTER_VERSION")
	if target == "" {
		println("Env ${FLUTTER_VERSION} is not set")
		os.Exit(1)
	}
	// get BRANCH
	branch := os.Getenv("BRANCH")
	if target == "" {
		println("Env ${BRANCH} is not set")
		os.Exit(1)
	}
	//
	var releaseFileName = commons.AssetName(version, flutterVersion, target, branch)
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
