package comic_center

import (
	"gorm.io/gorm"
	"time"
)

type Category struct {
	ID                string `gorm:"primarykey"`
	CreatedAt         time.Time
	UpdatedAt         time.Time
	DeletedAt         gorm.DeletedAt `gorm:"index"`
	Title             string         `json:"title"`
	Description       string         `json:"description"`
	IsWeb             bool           `json:"isWeb"`
	Active            bool           `json:"active"`
	Link              string         `json:"link"`
	ThumbOriginalName string
	ThumbFileServer   string
	ThumbPath         string
}

type RemoteImage struct {
	gorm.Model
	FileServer string `gorm:"index:uk_fp,unique" json:"fileServer"`
	Path       string `gorm:"index:uk_fp,unique" json:"path"`
	FileSize   int64  `json:"fileSize"`
	Format     string `json:"format"`
	Width      int32  `json:"width"`
	Height     int32  `json:"height"`
	LocalPath  string `json:"localPath"`
}

type ComicSimple struct {
	ID                string    `gorm:"primarykey" json:"id"`
	CreatedAt         time.Time `json:"createdAt"`
	UpdatedAt         time.Time `json:"updatedAt"`
	Title             string    `json:"title"`
	Author            string    `json:"author"`
	PagesCount        int32     `json:"pagesCount"`
	EpsCount          int32     `json:"epsCount"`
	Finished          bool      `json:"finished"`
	Categories        string    `json:"categories"`
	ThumbOriginalName string    `json:"thumbOriginalName"`
	ThumbFileServer   string    `json:"thumbFileServer"`
	ThumbPath         string    `json:"thumbPath"`
}

type ComicInfo struct {
	ComicSimple
	LikesCount    int32  `json:"likesCount"`
	Description   string `json:"description"`
	ChineseTeam   string `json:"chineseTeam"`
	Tags          string `json:"tags"`
	AllowDownload bool   `json:"allowDownload"`
	ViewsCount    int32  `json:"viewsCount"`
	IsFavourite   bool   `json:"isFavourite"`
	IsLiked       bool   `json:"isLiked"`
	CommentsCount int32  `json:"commentsCount"`
}

type ComicView struct {
	ComicInfo
	LastViewTime        time.Time `json:"lastViewTime"`
	LastViewEpOrder     int32     `json:"lastViewEpOrder"`
	LastViewEpTitle     string    `json:"lastViewEpTitle"`
	LastViewPictureRank int32     `json:"lastViewPictureRank"`
}

type ComicDownload struct {
	ComicSimple
	Description          string    `json:"description"`
	ChineseTeam          string    `json:"chineseTeam"`
	Tags                 string    `json:"tags"`
	SelectedEpCount      int32     `json:"selectedEpCount"`
	SelectedPictureCount int32     `json:"selectedPictureCount"`
	DownloadEpCount      int32     `json:"downloadEpCount"`
	DownloadPictureCount int32     `json:"downloadPictureCount"`
	DownloadFinished     bool      `json:"downloadFinished"`
	DownloadFinishedTime time.Time `json:"downloadFinishedTime"`
	DownloadFailed       bool      `json:"downloadFailed"`
	Deleting             bool      `json:"deleting"`
	ThumbFileSize        int64     `json:"thumbFileSize"`
	ThumbFormat          string    `json:"thumbFormat"`
	ThumbWidth           int32     `json:"thumbWidth"`
	ThumbHeight          int32     `json:"thumbHeight"`
	ThumbLocalPath       string    `json:"thumbLocalPath"`
	Pause                bool      `json:"pause"`
}

type ComicDownloadEp struct {
	ComicId              string    `gorm:"index:idx_comic_id" json:"comicId"`
	ID                   string    `gorm:"primarykey" json:"id"`
	UpdatedAt            time.Time `json:"updated_at"`
	EpOrder              int32     `json:"epOrder"`
	Title                string    `json:"title"`
	FetchedPictures      bool      `json:"fetchedPictures"`
	SelectedPictureCount int32     `json:"selectedPictureCount"`
	DownloadPictureCount int32     `json:"downloadPictureCount"`
	DownloadFinished     bool      `json:"downloadFinish"`
	DownloadFinishedTime time.Time `json:"downloadFinishTime"`
	DownloadFailed       bool      `json:"downloadFailed"`
}

type ComicDownloadPicture struct {
	ID                   string    `gorm:"primarykey" json:"id"`
	ComicId              string    `gorm:"index:idx_comic_id" json:"comicId"`
	EpId                 string    `gorm:"index:idx_ep_id" json:"epId"`
	EpOrder              int32     `gorm:"index:idx_ep_order" json:"epOrder"`
	RankInEp             int32     `json:"rankInEp"`
	DownloadFinished     bool      `json:"downloadFinish"`
	DownloadFinishedTime time.Time `json:"downloadFinishTime"`
	DownloadFailed       bool      `json:"downloadFailed"`
	OriginalName         string
	FileServer           string `gorm:"index:idx_fp,priority:1" json:"fileServer"`
	Path                 string `gorm:"index:idx_fp,priority:2" json:"path"`
	FileSize             int64  `json:"fileSize"`
	Format               string `json:"format"`
	Width                int32  `json:"width"`
	Height               int32  `json:"height"`
	LocalPath            string `json:"localPath"`
}
