package controller

import (
	"archive/tar"
	"archive/zip"
	"compress/gzip"
	"encoding/json"
	"gorm.io/gorm"
	"io"
	"io/ioutil"
	"net"
	"os"
	path2 "path"
	"pgo/pikapi/const_value"
	"pgo/pikapi/database/comic_center"
	"pgo/pikapi/utils"
	"strconv"
	"strings"
)

func importComicDownloadUsingSocket(addr string) error {
	//
	conn, err := net.Dial("tcp", addr)
	if err != nil {
		return err
	}
	defer conn.Close()
	gr, err := gzip.NewReader(conn)
	if err != nil {
		return err
	}
	tr := tar.NewReader(gr)
	//
	zipPath := path2.Join(tmpDir, "tmp.zip")
	closed := false
	zipFile, err := os.Create(zipPath)
	if err != nil {
		return err
	}
	defer func() {
		if !closed {
			zipFile.Close()
		}
		os.Remove(zipPath)
	}()
	zipWriter := zip.NewWriter(zipFile)
	defer func() {
		if !closed {
			zipWriter.Close()
		}
	}()
	//
	for {
		header, err := tr.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			return err
		}
		if header.Typeflag != tar.TypeReg {
			continue
		}
		writer, err := zipWriter.Create(header.Name)
		if err != nil {
			return err
		}
		_, err = io.Copy(writer, tr)
		if err != nil {
			return err
		}
	}
	err = zipWriter.Close()
	zipFile.Close()
	closed = true
	return importComicDownload(zipPath)
}

func importComicDownload(zipPath string) error {
	zip, err := zip.OpenReader(zipPath)
	if err != nil {
		return err
	}
	defer zip.Close()
	dataJs, err := zip.Open("data.js")
	if err != nil {
		return err
	}
	defer dataJs.Close()
	dataBuff, err := ioutil.ReadAll(dataJs)
	if err != nil {
		return err
	}
	data := strings.TrimLeft(string(dataBuff), "data = ")
	var jsonComicDownload JsonComicDownload
	err = json.Unmarshal([]byte(data), &jsonComicDownload)
	if err != nil {
		return err
	}
	return comic_center.Transaction(func(tx *gorm.DB) error {
		// 删除
		err := tx.Unscoped().Delete(&comic_center.ComicDownload{}, "id = ?", jsonComicDownload.ID).Error
		if err != nil {
			return err
		}
		err = tx.Unscoped().Delete(&comic_center.ComicDownloadEp{}, "comic_id = ?", jsonComicDownload.ID).Error
		if err != nil {
			return err
		}
		err = tx.Unscoped().Delete(&comic_center.ComicDownloadPicture{}, "comic_id = ?", jsonComicDownload.ID).Error
		if err != nil {
			return err
		}
		// 插入
		err = tx.Save(&jsonComicDownload.ComicDownload).Error
		if err != nil {
			return err
		}
		for _, ep := range jsonComicDownload.EpList {
			err = tx.Save(&ep.ComicDownloadEp).Error
			if err != nil {
				return err
			}
			for _, picture := range ep.PictureList {
				notifyExport("事务 : " + picture.LocalPath)
				err = tx.Save(&picture.ComicDownloadPicture).Error
				if err != nil {
					return err
				}
			}
		}
		// VIEW日志
		view := comic_center.ComicView{}
		view.ID = jsonComicDownload.ID
		view.CreatedAt = jsonComicDownload.CreatedAt
		view.UpdatedAt = jsonComicDownload.UpdatedAt
		view.Title = jsonComicDownload.Title
		view.Author = jsonComicDownload.Author
		view.PagesCount = jsonComicDownload.PagesCount
		view.EpsCount = jsonComicDownload.EpsCount
		view.Finished = jsonComicDownload.Finished
		c, _ := json.Marshal(jsonComicDownload.Categories)
		view.Categories = string(c)
		view.ThumbOriginalName = jsonComicDownload.ThumbOriginalName
		view.ThumbFileServer = jsonComicDownload.ThumbFileServer
		view.ThumbPath = jsonComicDownload.ThumbPath
		view.LikesCount = 0
		view.Description = jsonComicDownload.Description
		view.ChineseTeam = jsonComicDownload.ChineseTeam
		t, _ := json.Marshal(jsonComicDownload.Tags)
		view.Tags = string(t)
		view.AllowDownload = true
		view.ViewsCount = 0
		view.IsFavourite = false
		view.IsLiked = false
		view.CommentsCount = 0
		err = comic_center.NoLockActionViewComicUpdateInfoDB(&view, tx)
		if err != nil {
			return err
		}
		// 覆盖文件
		comicDirPath := downloadPath(jsonComicDownload.ID)
		utils.Mkdir(comicDirPath)
		logoReader, err := zip.Open("logo")
		if err == nil {
			defer logoReader.Close()
			logoBuff, err := ioutil.ReadAll(logoReader)
			if err != nil {
				return err
			}
			ioutil.WriteFile(path2.Join(comicDirPath, "logo"), logoBuff, const_value.CreateFileMode)
		}
		for _, ep := range jsonComicDownload.EpList {
			utils.Mkdir(path2.Join(comicDirPath, strconv.Itoa(int(ep.EpOrder))))
			for _, picture := range ep.PictureList {
				notifyExport("写入 : " + picture.LocalPath)
				zipEntry, err := zip.Open(picture.SrcPath)
				if err != nil {
					return err
				}
				err = func() error {
					defer zipEntry.Close()
					entryBuff, err := ioutil.ReadAll(zipEntry)
					if err != nil {
						return err
					}
					return ioutil.WriteFile(downloadPath(picture.LocalPath), entryBuff, const_value.CreateFileMode)
				}()
				if err != nil {
					return err
				}
			}
		}
		// 结束
		return nil
	})
}
