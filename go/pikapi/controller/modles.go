package controller

import "pgo/pikapi/database/comic_center"

type DisplayImageData struct {
	FileSize  int64  `json:"fileSize"`
	Format    string `json:"format"`
	Width     int32  `json:"width"`
	Height    int32  `json:"height"`
	FinalPath string `json:"finalPath"`
}

type ComicDownloadPictureWithFinalPath struct {
	comic_center.ComicDownloadPicture
	FinalPath string `json:"finalPath"`
}

type JsonComicDownload struct {
	comic_center.ComicDownload
	EpList []JsonComicDownloadEp `json:"epList"`
}

type JsonComicDownloadEp struct {
	comic_center.ComicDownloadEp
	PictureList []JsonComicDownloadPicture `json:"pictureList"`
}

type JsonComicDownloadPicture struct {
	comic_center.ComicDownloadPicture
	SrcPath string `json:"srcPath"`
}
