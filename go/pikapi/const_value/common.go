package const_value

import (
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"os"
)

var (
	CreateDirMode  = os.FileMode(0700)
	CreateFileMode = os.FileMode(0600)
	GormConfig     = &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	}
)

