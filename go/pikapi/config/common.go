package config

import (
	"path"
	"pgo/pikapi/controller"
	"pgo/pikapi/database/comic_center"
	"pgo/pikapi/database/network_cache"
	"pgo/pikapi/database/properties"
	"pgo/pikapi/utils"
)

// InitApplication 由不同的平台直接调用, 根据提供的路径初始化数据库, 资料文件夹
func InitApplication(applicationDir string) {
	println("初始化 : " + applicationDir)
	var databasesDir, remoteDir, downloadDir, tmpDir string
	databasesDir = path.Join(applicationDir, "databases")
	remoteDir = path.Join(applicationDir, "pictures", "remote")
	downloadDir = path.Join(applicationDir, "download")
	tmpDir = path.Join(applicationDir, "download")
	utils.Mkdir(databasesDir)
	utils.Mkdir(remoteDir)
	utils.Mkdir(downloadDir)
	utils.Mkdir(tmpDir)
	properties.InitDBConnect(databasesDir)
	network_cache.InitDBConnect(databasesDir)
	comic_center.InitDBConnect(databasesDir)
	controller.InitClient()
	controller.InitPlugin(remoteDir, downloadDir, tmpDir)
}
