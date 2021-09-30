package controller

import (
	"crypto/md5"
	"encoding/json"
	"errors"
	"fmt"
	source "github.com/niuhuan/pica-go"
	"image/jpeg"
	"io/ioutil"
	"os"
	path2 "path"
	"pgo/pikapi/const_value"
	"pgo/pikapi/database/comic_center"
	"pgo/pikapi/database/network_cache"
	"pgo/pikapi/database/properties"
	"pgo/pikapi/utils"
	"strconv"
	"time"
)

var (
	remoteDir   string
	downloadDir string
	tmpDir      string
)

func InitPlugin(_remoteDir string, _downloadDir string, _tmpDir string) {
	remoteDir = _remoteDir
	downloadDir = _downloadDir
	tmpDir = _tmpDir
	comic_center.ResetAll()
	go downloadBackground()
	downloadRunning = true
}

func remotePath(path string) string {
	return path2.Join(remoteDir, path)
}

func downloadPath(path string) string {
	return path2.Join(downloadDir, path)
}

func saveProperty(params string) error {
	var paramsStruct struct {
		Name  string `json:"name"`
		Value string `json:"value"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	return properties.SaveProperty(paramsStruct.Name, paramsStruct.Value)
}

func loadProperty(params string) (string, error) {
	var paramsStruct struct {
		Name         string `json:"name"`
		DefaultValue string `json:"defaultValue"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	return properties.LoadProperty(paramsStruct.Name, paramsStruct.DefaultValue)
}

func setSwitchAddress(nSwitchAddress string) error {
	err := properties.SaveSwitchAddress(nSwitchAddress)
	if err != nil {
		return err
	}
	switchAddress = nSwitchAddress
	return nil
}

func getSwitchAddress() (string, error) {
	return switchAddress, nil
}

func setProxy(value string) error {
	err := properties.SaveProxy(value)
	if err != nil {
		return err
	}
	changeProxyUrl(value)
	return nil
}

func getProxy() (string, error) {
	return properties.LoadProxy()
}

func setUsername(value string) error {
	return properties.SaveUsername(value)
}

func getUsername() (string, error) {
	return properties.LoadUsername()
}

func setPassword(value string) error {
	return properties.SavePassword(value)
}

func getPassword() (string, error) {
	return properties.LoadPassword()
}

func preLogin() (string, error) {
	token, _ := properties.LoadToken()
	tokenTime, _ := properties.LoadTokenTime()
	if token != "" && tokenTime > 0 {
		if utils.Timestamp()-(1000*60*60*24) < tokenTime {
			client.Token = token
			return "true", nil
		}
	}
	err := login()
	if err == nil {
		return "true", nil
	}
	return "false", nil
}

func login() error {
	username, _ := properties.LoadUsername()
	password, _ := properties.LoadPassword()
	if password == "" || username == "" {
		return errors.New(" 需要设定用户名和密码 ")
	}
	err := client.Login(username, password)
	if err != nil {
		return err
	}
	properties.SaveToken(client.Token)
	properties.SaveTokenTime(utils.Timestamp())
	return nil
}

func register(params string) error {
	var dto source.RegisterDto
	err := json.Unmarshal([]byte(params), &dto)
	if err != nil {
		return err
	}
	return client.Register(dto)
}

func clearToken() error {
	properties.SaveTokenTime(0)
	properties.SaveToken("")
	return nil
}

func userProfile() (string, error) {
	return serialize(client.UserProfile())
}

func punchIn() (string, error) {
	return serialize(client.PunchIn())
}

func remoteImageData(params string) (string, error) {
	var paramsStruct struct {
		FileServer string `json:"fileServer"`
		Path       string `json:"path"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	fileServer := paramsStruct.FileServer
	path := paramsStruct.Path
	lock := utils.HashLock(fmt.Sprintf("%s$%s", fileServer, path))
	lock.Lock()
	defer lock.Unlock()
	cache := comic_center.FindRemoteImage(fileServer, path)
	if cache == nil {
		remote, err := decodeAndSaveImage(fileServer, path)
		if err != nil {
			return "", err
		}
		cache = remote
	}
	display := DisplayImageData{
		FileSize:  cache.FileSize,
		Format:    cache.Format,
		Width:     cache.Width,
		Height:    cache.Height,
		FinalPath: remotePath(cache.LocalPath),
	}
	return serialize(&display, nil)
}

func remoteImagePreload(params string) error {
	var paramsStruct struct {
		FileServer string `json:"fileServer"`
		Path       string `json:"path"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	fileServer := paramsStruct.FileServer
	path := paramsStruct.Path
	lock := utils.HashLock(fmt.Sprintf("%s$%s", fileServer, path))
	lock.Lock()
	defer lock.Unlock()
	cache := comic_center.FindRemoteImage(fileServer, path)
	var err error
	if cache == nil {
		_, err = decodeAndSaveImage(fileServer, path)
	}
	return err
}

func decodeAndSaveImage(fileServer string, path string) (*comic_center.RemoteImage, error) {
	buff, img, format, err := decodeFromUrl(fileServer, path)
	if err != nil {
		println(fmt.Sprintf("decode error : %s/static/%s %s", fileServer, path, err.Error()))
		return nil, err
	}
	local :=
		fmt.Sprintf("%x",
			md5.Sum([]byte(fmt.Sprintf("%s$%s", fileServer, path))),
		)
	real := remotePath(local)
	err = ioutil.WriteFile(
		real,
		buff, os.FileMode(0600),
	)
	if err != nil {
		return nil, err
	}
	remote := comic_center.RemoteImage{
		FileServer: fileServer,
		Path:       path,
		FileSize:   int64(len(buff)),
		Format:     format,
		Width:      int32(img.Bounds().Dx()),
		Height:     int32(img.Bounds().Dy()),
		LocalPath:  local,
	}
	err = comic_center.SaveRemoteImage(&remote)
	return &remote, err
}

func downloadImagePath(path string) (string, error) {
	return downloadPath(path), nil
}

func createDownload(params string) error {
	var paramsStruct struct {
		Comic  comic_center.ComicDownload     `json:"comic"`
		EpList []comic_center.ComicDownloadEp `json:"epList"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	comic := paramsStruct.Comic
	epList := paramsStruct.EpList
	if comic.Title == "" || len(epList) == 0 {
		return errors.New("params error")
	}
	err := comic_center.CreateDownload(&comic, &epList)
	if err != nil {
		return err
	}
	// 创建文件夹
	utils.Mkdir(downloadPath(comic.ID))
	// 复制图标
	downloadComicLogo(&comic)
	return nil
}

func downloadComicLogo(comic *comic_center.ComicDownload) {
	lock := utils.HashLock(fmt.Sprintf("%s$%s", comic.ThumbFileServer, comic.ThumbPath))
	lock.Lock()
	defer lock.Unlock()
	buff, image, format, err := decodeFromCache(comic.ThumbFileServer, comic.ThumbPath)
	if err != nil {
		buff, image, format, err = decodeFromUrl(comic.ThumbFileServer, comic.ThumbPath)
	}
	if err == nil {
		comicLogoPath := path2.Join(comic.ID, "logo")
		ioutil.WriteFile(downloadPath(comicLogoPath), buff, const_value.CreateFileMode)
		comic_center.UpdateDownloadLogo(
			comic.ID,
			int64(len(buff)),
			format,
			int32(image.Bounds().Dx()),
			int32(image.Bounds().Dy()),
			comicLogoPath,
		)
		comic.ThumbFileSize = int64(len(buff))
		comic.ThumbFormat = format
		comic.ThumbWidth = int32(image.Bounds().Dx())
		comic.ThumbHeight = int32(image.Bounds().Dy())
		comic.ThumbLocalPath = comicLogoPath
	}
	if err != nil {
		println(err.Error())
	}
}

func addDownload(params string) error {
	var paramsStruct struct {
		Comic  comic_center.ComicDownload     `json:"comic"`
		EpList []comic_center.ComicDownloadEp `json:"epList"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	comic := paramsStruct.Comic
	epList := paramsStruct.EpList
	if comic.Title == "" || len(epList) == 0 {
		return errors.New("params error")
	}
	return comic_center.AddDownload(&comic, &epList)
}

func deleteDownloadComic(comicId string) error {
	err := comic_center.Deleting(comicId)
	if err != nil {
		return err
	}
	downloadRestart = true
	return nil
}

func loadDownloadComic(comicId string) (string, error) {
	download, err := comic_center.FindComicDownloadById(comicId)
	if err != nil {
		return "", err
	}
	if download == nil {
		return "", nil
	}
	comic_center.ViewComic(comicId) // VIEW
	return serialize(download, err)
}

func allDownloads() (string, error) {
	return serialize(comic_center.AllDownloads())
}

func downloadEpList(comicId string) (string, error) {
	return serialize(comic_center.ListDownloadEpByComicId(comicId))
}

func viewLogPage(params string) (string, error) {
	var paramsStruct struct {
		Offset int `json:"offset"`
		Limit  int `json:"limit"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	return serialize(comic_center.ViewLogPage(paramsStruct.Offset, paramsStruct.Limit))
}

func downloadPicturesByEpId(epId string) (string, error) {
	return serialize(comic_center.ListDownloadPictureByEpId(epId))
}

func getDownloadRunning() bool {
	return downloadRunning
}

func setDownloadRunning(status bool) {
	downloadRunning = status
}

func clean() error {
	var err error
	notifyExport("清理网络缓存")
	err = network_cache.RemoveAll()
	if err != nil {
		return err
	}
	notifyExport("清理图片缓存")
	err = comic_center.RemoveAllRemoteImage()
	if err != nil {
		return err
	}
	notifyExport("清理图片文件")
	os.RemoveAll(remoteDir)
	utils.Mkdir(remoteDir)
	notifyExport("清理结束")
	return nil
}

func autoClean(expire int64) error {
	now := time.Now()
	earliest := now.Add(time.Second * time.Duration(0-expire))
	err := network_cache.RemoveEarliest(earliest)
	if err != nil {
		return err
	}
	pageSize := 10
	for true {
		images, err := comic_center.EarliestRemoteImage(earliest, pageSize)
		if err != nil {
			return err
		}
		if len(images) == 0 {
			return comic_center.VACUUM()
		}
		// delete data & remove pic
		err = comic_center.DeleteRemoteImages(images)
		if err != nil {
			return err
		}
		for i := 0; i < len(images); i++ {
			err = os.Remove(remotePath(images[i].LocalPath))
			if err != nil {
				return err
			}
		}
	}
	return nil
}

func storeViewEp(params string) error {
	var paramsStruct struct {
		ComicId     string `json:"comicId"`
		EpOrder     int    `json:"epOrder"`
		EpTitle     string `json:"epTitle"`
		PictureRank int    `json:"pictureRank"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	return comic_center.ViewEpAndPicture(
		paramsStruct.ComicId,
		paramsStruct.EpOrder,
		paramsStruct.EpTitle,
		paramsStruct.PictureRank,
	)
}

func loadView(comicId string) (string, error) {
	view, err := comic_center.LoadViewLog(comicId)
	if err != nil {
		return "", nil
	}
	if view != nil {
		b, err := json.Marshal(view)
		if err != nil {
			return "", err
		}
		return string(b), nil
	}
	return "", nil
}

func convertImageToJPEG100(params string) error {
	var paramsStruct struct {
		Path string `json:"path"`
		Dir  string `json:"dir"`
	}
	err := json.Unmarshal([]byte(params), &paramsStruct)
	if err != nil {
		return err
	}
	_, i, _, err := decodeFromFile(paramsStruct.Path)
	if err != nil {
		return err
	}
	to := path2.Join(paramsStruct.Dir, path2.Base(paramsStruct.Path)+".jpg")
	stream, err := os.Create(to)
	if err != nil {
		return err
	}
	defer stream.Close()
	return jpeg.Encode(stream, i, &jpeg.Options{Quality: 100})
}

func FlatInvoke(method string, params string) (string, error) {
	switch method {
	case "saveProperty":
		return "", saveProperty(params)
	case "loadProperty":
		return loadProperty(params)
	case "setSwitchAddress":
		return "", setSwitchAddress(params)
	case "getSwitchAddress":
		return getSwitchAddress()
	case "setProxy":
		return "", setProxy(params)
	case "getProxy":
		return getProxy()
	case "setUsername":
		return "", setUsername(params)
	case "setPassword":
		return "", setPassword(params)
	case "getUsername":
		return getUsername()
	case "getPassword":
		return getPassword()
	case "preLogin":
		return preLogin()
	case "login":
		return "", login()
	case "register":
		return "", register(params)
	case "clearToken":
		return "", clearToken()
	case "userProfile":
		return userProfile()
	case "punchIn":
		return punchIn()
	case "categories":
		return categories()
	case "comics":
		return comics(params)
	case "searchComics":
		return searchComics(params)
	case "randomComics":
		return randomComics()
	case "leaderboard":
		return leaderboard(params)
	case "comicInfo":
		return comicInfo(params)
	case "comicEpPage":
		return epPage(params)
	case "comicPicturePageWithQuality":
		return comicPicturePageWithQuality(params)
	case "switchLike":
		return switchLike(params)
	case "switchFavourite":
		return switchFavourite(params)
	case "favouriteComics":
		return favouriteComics(params)
	case "recommendation":
		return recommendation(params)
	case "comments":
		return comments(params)
	case "commentChildren":
		return commentChildren(params)
	case "myComments":
		return myComments(params)
	case "postComment":
		return postComment(params)
	case "postChildComment":
		return postChildComment(params)
	case "game":
		return game(params)
	case "games":
		return games(params)
	case "viewLogPage":
		return viewLogPage(params)
	case "clearAllViewLog":
		comic_center.ClearAllViewLog()
		return "", nil
	case "deleteViewLog":
		comic_center.DeleteViewLog(params)
		return "", nil
	case "clean":
		return "", clean()
	case "autoClean":
		expire, err := strconv.ParseInt(params, 10, 64)
		if err != nil {
			return "", err
		}
		return "", autoClean(expire)
	case "storeViewEp":
		return "", storeViewEp(params)
	case "loadView":
		return loadView(params)
	case "downloadRunning":
		return strconv.FormatBool(getDownloadRunning()), nil
	case "setDownloadRunning":
		b, e := strconv.ParseBool(params)
		if e != nil {
			setDownloadRunning(b)
		}
		return "", e
	case "createDownload":
		return "", createDownload(params)
	case "addDownload":
		return "", addDownload(params)
	case "loadDownloadComic":
		return loadDownloadComic(params)
	case "allDownloads":
		return allDownloads()
	case "deleteDownloadComic":
		return "", deleteDownloadComic(params)
	case "downloadEpList":
		return downloadEpList(params)
	case "downloadPicturesByEpId":
		return downloadPicturesByEpId(params)
	case "resetAllDownloads":
		return "", comic_center.ResetAll()
	case "exportComicDownload":
		return "", exportComicDownload(params)
	case "exportComicDownloadToJPG":
		return "", exportComicDownloadToJPG(params)
	case "exportComicUsingSocket":
		i, e := exportComicUsingSocket(params)
		return fmt.Sprintf("%d", i), e
	case "exportComicUsingSocketExit":
		return "", exportComicUsingSocketExit()
	case "importComicDownload":
		return "", importComicDownload(params)
	case "importComicDownloadUsingSocket":
		return "", importComicDownloadUsingSocket(params)
	case "remoteImageData":
		return remoteImageData(params)
	case "remoteImagePreload":
		return "", remoteImagePreload(params)
	case "clientIpSet":
		return clientIpSet()
	case "downloadImagePath":
		return downloadImagePath(params)
	case "downloadGame":
		return downloadGame(params)
	case "convertImageToJPEG100":
		return "", convertImageToJPEG100(params)
	}
	return "", errors.New("method not found : " + method)
}
