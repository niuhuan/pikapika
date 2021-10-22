package controller

import "pikapi/main/database/comic_center"

// 根据comicId，获得标题，但是必须是下载的内容(暂未使用)
func specialDownloadTitle(comicId string) (string, error) {
	info, err := comic_center.DownloadInfo(comicId)
	if err != nil {
		return "", err
	}
	return info.Title, nil
}
