package network_cache

import (
	"errors"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
	"path"
	"pgo/pikapi/const_value"
	"sync"
	"time"
)

var mutex = sync.Mutex{}
var db *gorm.DB

type NetworkCache struct {
	gorm.Model
	K string `gorm:"index:uk_k,unique"`
	V string
}

func InitDBConnect(databaseDir string) {
	mutex.Lock()
	defer mutex.Unlock()
	var err error
	db, err = gorm.Open(sqlite.Open(path.Join(databaseDir, "network_cache.db")), const_value.GormConfig)
	if err != nil {
		panic("failed to connect database")
	}
	db.AutoMigrate(&NetworkCache{})
}

func LoadCache(key string, expire time.Duration) string {
	mutex.Lock()
	defer mutex.Unlock()
	var cache NetworkCache
	err := db.First(&cache, "k = ? AND updated_at > ?", key, time.Now().Add(expire*-1)).Error
	if err == nil {
		return cache.V
	}
	if gorm.ErrRecordNotFound == err {
		return ""
	}
	panic(errors.New("?"))
}

func SaveCache(key string, value string) {
	mutex.Lock()
	defer mutex.Unlock()
	db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "k"}},
		DoUpdates: clause.AssignmentColumns([]string{"created_at", "updated_at", "v"}),
	}).Create(&NetworkCache{
		K: key,
		V: value,
	})
}

func RemoveCache(key string) error {
	mutex.Lock()
	defer mutex.Unlock()
	err := db.Unscoped().Delete(&NetworkCache{}, "k = ?", key).Error
	if err == gorm.ErrRecordNotFound {
		return nil
	}
	return err
}

func RemoveCaches(like string) error {
	mutex.Lock()
	defer mutex.Unlock()
	err := db.Unscoped().Delete(&NetworkCache{}, "k LIKE ?", like).Error
	if err == gorm.ErrRecordNotFound {
		return nil
	}
	return err
}

func RemoveAll() error {
	mutex.Lock()
	defer mutex.Unlock()
	err := db.Unscoped().Delete(&NetworkCache{}, "1 = 1").Error
	if err != nil {
		return err
	}
	return db.Raw("VACUUM").Error
}

func RemoveEarliest(earliest time.Time) error {
	mutex.Lock()
	defer mutex.Unlock()
	err := db.Unscoped().Where("strftime('%s',updated_at) < strftime('%s',?)", earliest).
		Delete(&NetworkCache{}).Error
	if err != nil {
		return err
	}
	return db.Raw("VACUUM").Error
}
