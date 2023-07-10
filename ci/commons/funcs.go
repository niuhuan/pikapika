package commons

import (
	"fmt"
	"io/ioutil"
	"strings"
)

const Owner = "niuhuan"
const Repo = "pikapika"
const Ua = "niuhuan pikapika ci"
const MainBranch = "master"

func LoadVersion() Version {
	var version Version
	codeFile, err := ioutil.ReadFile("version.code.txt")
	if err != nil {
		panic(err)
	}
	version.Code = strings.TrimSpace(string(codeFile))
	infoFile, err := ioutil.ReadFile("version.info.txt")
	if err != nil {
		panic(err)
	}
	version.Info = strings.TrimSpace(string(infoFile))
	return version
}

func AssetName(version Version, flutterVersion, target, branch string) string {
	releaseFileName := fmt.Sprintf("pikapika-%v_flutter-%v", version.Code, flutterVersion)
	switch target {
	case "macos":
		releaseFileName += "-macos-intel.dmg"
	case "ios":
		releaseFileName += "-ios-nosign.ipa"
	case "windows":
		releaseFileName += "-windows-x86_64.zip"
	case "linux":
		releaseFileName += "-linux-x86_64.AppImage"
	case "android-arm32":
		releaseFileName += "-android-arm32.apk"
	case "android-arm64":
		releaseFileName += "-android-arm64.apk"
	case "android-x86_64":
		releaseFileName += "-android-x86_64.apk"
	}
	if branch != "master" && branch != "main" {
		releaseFileName = branch + "-" + releaseFileName
	}
	return releaseFileName
}
