package controller

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"pgo/pikapi/const_value"
	"pgo/pikapi/database/comic_center"
	utils2 "pgo/pikapi/utils"
	"time"
)

var downloadRunning = false
var downloadRestart = false

var downloadingComic *comic_center.ComicDownload
var downloadingEp *comic_center.ComicDownloadEp
var downloadingPicture *comic_center.ComicDownloadPicture

func downloadBackground() {
	println("后台线程启动")
	go downloadBegin()
}

func downloadBegin() {
	time.Sleep(time.Second * 3)
	go downloadLoadComic()
}

func downloadHasStop() bool {
	if !downloadRunning {
		go downloadBegin()
		return true
	}
	if downloadRestart {
		downloadRestart = false
		go downloadBegin()
		return true
	}
	return false
}

func downloadDelete() bool {
	c, e := comic_center.DeletingComic()
	if e != nil {
		panic(e)
	}
	if c != nil {
		os.RemoveAll(downloadPath(c.ID))
		e = comic_center.TrueDelete(c.ID)
		if e != nil {
			panic(e)
		}
		return true
	}
	return false
}

func downloadLoadComic() {
	for downloadDelete() {
	}
	if downloadHasStop() {
		return
	}
	var err error
	downloadingComic, err = comic_center.LoadFirstNeedDownload()
	// 查库有错误就停止
	if err != nil {
		panic(err)
	}
	go downloadInitComic()
}

func downloadInitComic() {
	if downloadHasStop() {
		return
	}
	if downloadingComic == nil {
		println("没有找到要下载的漫画")
		go downloadBegin()
		return
	}
	println("正在下载漫画 " + downloadingComic.Title)
	downloadComicEventSend(downloadingComic)
	eps, err := comic_center.ListDownloadEpByComicId(downloadingComic.ID)
	if err != nil {
		panic(err)
	}
	for _, ep := range eps {
		if !ep.FetchedPictures {
			println("正在获取章节的图片 " + downloadingComic.Title + " " + ep.Title)
			for i := 0; i < 5; i++ {
				if client.Token == "" {
					continue
				}
				err := downloadFetchPictures(&ep)
				if err != nil {
					println(err.Error())
					continue
				}
				ep.FetchedPictures = true
				break
			}
			if !ep.FetchedPictures {
				println("章节的图片获取失败 " + downloadingComic.Title + " " + ep.Title)
				err = comic_center.EpFailed(ep.ID)
				if err != nil {
					panic(err)
				}
			} else {
				println("章节的图片获取成功 " + downloadingComic.Title + " " + ep.Title)
				downloadingComic.SelectedPictureCount = downloadingComic.SelectedPictureCount + ep.SelectedPictureCount
				downloadComicEventSend(downloadingComic)
			}
		}
	}
	go downloadLoadEp()
}

func downloadFetchPictures(downloadEp *comic_center.ComicDownloadEp) error {
	var list []comic_center.ComicDownloadPicture
	page := 1
	for true {
		rsp, err := client.ComicPicturePage(downloadingComic.ID, int(downloadEp.EpOrder), page)
		if err != nil {
			return err
		}
		for _, doc := range rsp.Docs {
			list = append(list, comic_center.ComicDownloadPicture{
				ID:           doc.Id,
				ComicId:      downloadEp.ComicId,
				EpId:         downloadEp.ID,
				EpOrder:      downloadEp.EpOrder,
				OriginalName: doc.Media.OriginalName,
				FileServer:   doc.Media.FileServer,
				Path:         doc.Media.Path,
			})
		}
		if rsp.Page.Page < rsp.Page.Pages {
			page++
			continue
		}
		break
	}
	err := comic_center.FetchPictures(downloadEp.ComicId, downloadEp.ID, &list)
	if err != nil {
		panic(err)
	}
	downloadEp.SelectedPictureCount = int32(len(list))
	return err
}

func downloadLoadEp() {
	if downloadHasStop() {
		return
	}
	var err error
	downloadingEp, err = comic_center.LoadFirstNeedDownloadEp(downloadingComic.ID)
	if err != nil {
		panic(err)
	}
	go downloadInitEp()
}

func downloadInitEp() {
	if downloadingEp == nil {
		// 所有Ep都下完了, 汇总Download下载情况
		go downloadSummaryDownload()
		return
	}
	println("正在下载章节 " + downloadingEp.Title)
	go downloadLoadPicture()
}

func downloadSummaryDownload() {
	if downloadHasStop() {
		return
	}
	list, err := comic_center.ListDownloadEpByComicId(downloadingComic.ID)
	if err != nil {
		panic(err)
	}
	over := true
	for _, downloadEp := range list {
		over = over && downloadEp.DownloadFinished
	}
	if over {
		err = comic_center.DownloadSuccess(downloadingComic.ID)
		if err != nil {
			panic(err)
		}
		downloadingComic.DownloadFinished = true
		downloadingComic.DownloadFinishedTime = time.Now()
	} else {
		err = comic_center.DownloadFailed(downloadingComic.ID)
		if err != nil {
			panic(err)
		}
		downloadingComic.DownloadFailed = true
	}
	downloadComicEventSend(downloadingComic)
	go downloadLoadComic()
}

func downloadLoadPicture() {
	if downloadHasStop() {
		return
	}
	var err error
	downloadingPicture, err = comic_center.LoadFirstNeedDownloadPicture(downloadingEp.ID)
	if err != nil {
		panic(err)
	}
	go downloadInitPicture()
}

func downloadInitPicture() {
	if downloadHasStop() {
		return
	}
	if downloadingPicture == nil {
		// 所有图片都下完了, 汇总EP下载情况
		go downloadSummaryEp()
		return
	}
	println("正在下载图片 " + fmt.Sprintf("%d", downloadingPicture.RankInEp))
	for i := 0; i < 5; i++ {
		err := downloadThePicture(downloadingPicture)
		if err != nil {
			continue
		}
		downloadingPicture.DownloadFinished = true
		downloadingEp.DownloadPictureCount = downloadingEp.DownloadPictureCount + 1
		downloadingComic.DownloadPictureCount = downloadingComic.DownloadPictureCount + 1
		downloadComicEventSend(downloadingComic)
		break
	}
	if !downloadingPicture.DownloadFinished {
		err := comic_center.PictureFailed(downloadingPicture.ID)
		if err != nil {
			panic(err)
		}
	}
	go downloadLoadPicture()
}

func downloadThePicture(picturePoint *comic_center.ComicDownloadPicture) error {
	lock := utils2.HashLock(fmt.Sprintf("%s$%s", picturePoint.FileServer, picturePoint.Path))
	lock.Lock()
	defer lock.Unlock()
	picturePath := fmt.Sprintf("%s/%d/%d", picturePoint.ComicId, picturePoint.EpOrder, picturePoint.RankInEp)
	realPath := downloadPath(picturePath)
	// 从缓存
	buff, img, format, err := decodeFromCache(picturePoint.FileServer, picturePoint.Path)
	if err != nil {
		// 从网络
		buff, img, format, err = decodeFromUrl(picturePoint.FileServer, picturePoint.Path)
	}
	if err != nil {
		return err
	}
	dir := filepath.Dir(realPath)
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		os.Mkdir(dir, const_value.CreateDirMode)
	}
	err = ioutil.WriteFile(downloadPath(picturePath), buff, const_value.CreateFileMode)
	if err != nil {
		return err
	}
	return comic_center.PictureSuccess(
		picturePoint.ComicId,
		picturePoint.EpId,
		picturePoint.ID,
		int64(len(buff)),
		format,
		int32(img.Bounds().Dx()),
		int32(img.Bounds().Dy()),
		picturePath,
	)
}

func downloadSummaryEp() {
	if downloadHasStop() {
		return
	}
	list, err := comic_center.ListDownloadPictureByEpId(downloadingEp.ID)
	if err != nil {
		panic(err)
	}
	over := true
	for _, downloadPicture := range list {
		over = over && downloadPicture.DownloadFinished
	}
	if over {
		err = comic_center.EpSuccess(downloadingEp.ComicId, downloadingEp.ID)
		if err != nil {
			panic(err)
		}
	} else {
		err = comic_center.EpFailed(downloadingEp.ID)
		if err != nil {
			panic(err)
		}
	}
	go downloadLoadEp()
}
