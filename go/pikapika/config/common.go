package config

import (
	"path"
	"pikapika/pikapika"
	"pikapika/pikapika/database/comic_center"
	"pikapika/pikapika/database/network_cache"
	"pikapika/pikapika/database/properties"
	"pikapika/pikapika/utils"
)

// InitApplication 由不同的平台直接调用, 根据提供的路径初始化数据库, 资料文件夹
func InitApplication(applicationDir string) {
	println("初始化 : " + applicationDir)
	var databasesDir, remoteDir, downloadDir, tmpDir string
	databasesDir = path.Join(applicationDir, "databases")
	remoteDir = path.Join(applicationDir, "pictures", "remote")
	downloadDir = path.Join(applicationDir, "download")
	tmpDir = path.Join(applicationDir, "tmp")
	utils.Mkdir(databasesDir)
	utils.Mkdir(remoteDir)
	utils.Mkdir(downloadDir)
	utils.Mkdir(tmpDir)
	properties.InitDBConnect(databasesDir)
	network_cache.InitDBConnect(databasesDir)
	comic_center.InitDBConnect(databasesDir)
	pikapika.InitClient()
	pikapika.InitPlugin(remoteDir, downloadDir, tmpDir)
}
