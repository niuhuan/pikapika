package controller

import "pgo/pikapi/database/comic_center"

func specialDownloadTitle(comicId string) (string, error) {
	info, err := comic_center.DownloadInfo(comicId)
	if err != nil {
		return "", err
	}
	return info.Title, nil
}
