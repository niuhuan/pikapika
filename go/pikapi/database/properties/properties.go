package properties

import (
	"errors"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
	"path"
	"pgo/pikapi/const_value"
	"strconv"
	"sync"
)

var mutex = sync.Mutex{}
var db *gorm.DB

func InitDBConnect(databaseDir string) {
	mutex.Lock()
	defer mutex.Unlock()
	var err error
	db, err = gorm.Open(sqlite.Open(path.Join(databaseDir, "properties.db")), const_value.GormConfig)
	if err != nil {
		panic("failed to connect database")
	}
	db.AutoMigrate(&Property{})
}

type Property struct {
	gorm.Model
	K string `gorm:"index:uk_k,unique"`
	V string
}

func LoadProperty(name string, defaultValue string) (string, error) {
	mutex.Lock()
	defer mutex.Unlock()
	var property Property
	err := db.First(&property, "k", name).Error
	if err == nil {
		return property.V, nil
	}
	if gorm.ErrRecordNotFound == err {
		return defaultValue, nil
	}
	panic(errors.New("?"))
}

func SaveProperty(name string, value string) error {
	mutex.Lock()
	defer mutex.Unlock()
	return db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "k"}},
		DoUpdates: clause.AssignmentColumns([]string{"created_at", "updated_at", "v"}),
	}).Create(&Property{
		K: name,
		V: value,
	}).Error
}

func LoadBoolProperty(name string, defaultValue bool) (bool, error) {
	stringValue, err := LoadProperty(name, strconv.FormatBool(defaultValue))
	if err != nil {
		return false, err
	}
	return strconv.ParseBool(stringValue)
}

func SaveBoolProperty(name string, value bool) error {
	return SaveProperty(name, strconv.FormatBool(value))
}

func SaveSwitchAddress(value string) error {
	return SaveProperty("switch_address", value)
}

func LoadSwitchAddress() (string, error) {
	return LoadProperty("switch_address", "")
}

func SaveProxy(value string) error {
	return SaveProperty("proxy", value)
}

func LoadProxy() (string, error) {
	return LoadProperty("proxy", "")
}

func SaveUsername(value string) error {
	return SaveProperty("username", value)
}

func LoadUsername() (string, error) {
	return LoadProperty("username", "")
}

func SavePassword(value string) error {
	return SaveProperty("password", value)
}

func LoadPassword() (string, error) {
	return LoadProperty("password", "")
}

func SaveToken(value string) {
	SaveProperty("token", value)
}

func LoadToken() (string, error) {
	return LoadProperty("token", "")
}

func SaveTokenTime(value int64) {
	SaveProperty("token_time", strconv.FormatInt(value, 10))
}

func LoadTokenTime() (int64, error) {
	str, err := LoadProperty("token_time", "0")
	if err != nil {
		return 0, err
	}
	return strconv.ParseInt(str, 10, 64)
}
