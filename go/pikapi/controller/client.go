package controller

import (
	"context"
	"encoding/json"
	"fmt"
	source "github.com/niuhuan/pica-go"
	"net"
	"net/http"
	"net/url"
	"pgo/pikapi/database/comic_center"
	"pgo/pikapi/database/network_cache"
	"pgo/pikapi/database/properties"
	"regexp"
	"strconv"
	"strings"
	"time"
)

func InitClient() {
	client.Timeout = time.Second * 60
	switchAddress, _ = properties.LoadSwitchAddress()
	proxy, _ := properties.LoadProxy()
	changeProxyUrl(proxy)
}

var client = source.Client{}
var dialer = &net.Dialer{
	Timeout:   30 * time.Second,
	KeepAlive: 30 * time.Second,
}

// SwitchAddress
// addr = "172.67.7.24:443"
// addr = "104.20.180.50:443"
// addr = "172.67.208.169:443"
var switchAddress = ""
var switchAddressPattern, _ = regexp.Compile("^.+picacomic\\.com:\\d+$")

func switchAddressContext(ctx context.Context, network, addr string) (net.Conn, error) {
	if switchAddressPattern.MatchString(addr) && switchAddress != "" {
		addr = switchAddress
	}
	return dialer.DialContext(ctx, network, addr)
}

func changeProxyUrl(urlStr string) bool {
	if urlStr == "" {
		client.Transport = &http.Transport{
			TLSHandshakeTimeout:   time.Second * 10,
			ExpectContinueTimeout: time.Second * 10,
			ResponseHeaderTimeout: time.Second * 10,
			IdleConnTimeout:       time.Second * 10,
			DialContext:           switchAddressContext,
		}
		return false
	}
	client.Transport = &http.Transport{
		Proxy: func(_ *http.Request) (*url.URL, error) {
			return url.Parse(urlStr)
		},
		TLSHandshakeTimeout:   time.Second * 10,
		ExpectContinueTimeout: time.Second * 10,
		ResponseHeaderTimeout: time.Second * 10,
		IdleConnTimeout:       time.Second * 10,
		DialContext:           switchAddressContext,
	}
	return true
}

func cacheable(key string, expire time.Duration, reload func() (interface{}, error)) (string, error) {
	// CACHE
	cache := network_cache.LoadCache(key, expire)
	if cache != "" {
		return cache, nil
	}
	// obj
	obj, err := reload()
	if err != nil {
		return "", err
	}
	buff, err := json.Marshal(obj)
	// push to cache
	if err != nil {
		return "", err
	}
	// return
	cache = string(buff)
	network_cache.SaveCache(key, cache)
	return cache, nil
}

func categories() (string, error) {
	key := "CATEGORIES"
	expire := time.Hour * 3
	cache := network_cache.LoadCache(key, expire)
	if cache != "" {
		return cache, nil
	}
	categories, err := client.Categories()
	if err != nil {
		return "", err
	}
	var dbCategories []comic_center.Category
	for _, c := range categories {
		dbCategories = append(dbCategories, comic_center.Category{
			ID:                c.Id,
			Title:             c.Title,
			Description:       c.Description,
			IsWeb:             c.IsWeb,
			Active:            c.Active,
			Link:              c.Link,
			ThumbOriginalName: c.Thumb.OriginalName,
			ThumbFileServer:   c.Thumb.FileServer,
			ThumbPath:         c.Thumb.Path,
		})
	}
	err = comic_center.UpSetCategories(&dbCategories)
	if err != nil {
		return "", err
	}
	buff, _ := json.Marshal(&categories)
	cache = string(buff)
	network_cache.SaveCache(key, cache)
	return cache, nil
}

func comics(params string) (string, error) {
	var paramsStruct struct {
		Category    string `json:"category"`
		Tag         string `json:"tag"`
		CreatorId   string `json:"creatorId"`
		ChineseTeam string `json:"chineseTeam"`
		Sort        string `json:"sort"`
		Page        int    `json:"page"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	return cacheable(
		fmt.Sprintf("COMICS$%s$%s$%s$%s$%s$%d", paramsStruct.Category, paramsStruct.Tag, paramsStruct.CreatorId, paramsStruct.ChineseTeam, paramsStruct.Sort, paramsStruct.Page),
		time.Hour*2,
		func() (interface{}, error) {
			return client.Comics(paramsStruct.Category, paramsStruct.Tag, paramsStruct.CreatorId, paramsStruct.ChineseTeam, paramsStruct.Sort, paramsStruct.Page)
		},
	)
}

func searchComics(params string) (string, error) {
	var paramsStruct struct {
		Categories []string `json:"categories"`
		Keyword    string   `json:"keyword"`
		Sort       string   `json:"sort"`
		Page       int      `json:"page"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	categories := paramsStruct.Categories
	keyword := paramsStruct.Keyword
	sort := paramsStruct.Sort
	page := paramsStruct.Page
	//
	var categoriesInKey string
	if len(categories) == 0 {
		categoriesInKey = ""
	} else {
		b, _ := json.Marshal(categories)
		categoriesInKey = string(b)
	}
	return cacheable(
		fmt.Sprintf("SEARCH$%s$%s$%s$%d", categoriesInKey, keyword, sort, page),
		time.Hour*2,
		func() (interface{}, error) {
			return client.SearchComics(categories, keyword, sort, page)
		},
	)
}

func randomComics() (string, error) {
	return cacheable(
		fmt.Sprintf("RANDOM"),
		time.Millisecond*1,
		func() (interface{}, error) {
			return client.RandomComics()
		},
	)
}

func leaderboard(typeName string) (string, error) {
	return cacheable(
		fmt.Sprintf("LEADERBOARD$%s", typeName),
		time.Second*200,
		func() (interface{}, error) {
			return client.Leaderboard(typeName)
		},
	)
}

func comicInfo(comicId string) (string, error) {
	var err error
	var comic *source.ComicInfo
	// cache
	key := fmt.Sprintf("COMIC_INFO$%s", comicId)
	expire := time.Hour * 24 * 7
	cache := network_cache.LoadCache(key, expire)
	if cache != "" {
		var co source.ComicInfo
		err = json.Unmarshal([]byte(cache), &co)
		if err != nil {
			panic(err)
			return "", err
		}
		comic = &co
	} else {
		// get
		comic, err = client.ComicInfo(comicId)
		if err != nil {
			return "", err
		}
		var buff []byte
		buff, err = json.Marshal(comic)
		if err != nil {
			return "", err
		}
		cache = string(buff)
		network_cache.SaveCache(key, cache)
	}
	// 标记历史记录
	view := comic_center.ComicView{}
	view.ID = comicId
	view.CreatedAt = comic.CreatedAt
	view.UpdatedAt = comic.UpdatedAt
	view.Title = comic.Title
	view.Author = comic.Author
	view.PagesCount = int32(comic.PagesCount)
	view.EpsCount = int32(comic.EpsCount)
	view.Finished = comic.Finished
	c, _ := json.Marshal(comic.Categories)
	view.Categories = string(c)
	view.ThumbOriginalName = comic.Thumb.OriginalName
	view.ThumbFileServer = comic.Thumb.FileServer
	view.ThumbPath = comic.Thumb.Path
	view.LikesCount = int32(comic.LikesCount)
	view.Description = comic.Description
	view.ChineseTeam = comic.ChineseTeam
	t, _ := json.Marshal(comic.Tags)
	view.Tags = string(t)
	view.AllowDownload = comic.AllowDownload
	view.ViewsCount = int32(comic.ViewsCount)
	view.IsFavourite = comic.IsFavourite
	view.IsLiked = comic.IsLiked
	view.CommentsCount = int32(comic.CommentsCount)
	err = comic_center.ViewComicUpdateInfo(&view)
	if err != nil {
		return "", err
	}
	// return
	return cache, nil
}

func ComicInfoCleanCache(comicId string) {
	key := fmt.Sprintf("COMIC_INFO$%s", comicId)
	network_cache.RemoveCache(key)
}

func epPage(params string) (string, error) {
	var paramsStruct struct {
		ComicId string `json:"comicId"`
		Page    int    `json:"page"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	comicId := paramsStruct.ComicId
	page := paramsStruct.Page
	//
	return cacheable(
		fmt.Sprintf("COMIC_EP_PAGE$%s$%d", comicId, page),
		time.Hour*2,
		func() (interface{}, error) {
			return client.ComicEpPage(comicId, page)
		},
	)
}

func comicPicturePageWithQuality(params string) (string, error) {
	var paramsStruct struct {
		ComicId string `json:"comicId"`
		EpOrder int    `json:"epOrder"`
		Page    int    `json:"page"`
		Quality string `json:"quality"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	comicId := paramsStruct.ComicId
	epOrder := paramsStruct.EpOrder
	page := paramsStruct.Page
	quality := paramsStruct.Quality
	//
	return cacheable(
		fmt.Sprintf("COMIC_EP_PAGE$%s$%ds$%ds$%s", comicId, epOrder, page, quality),
		time.Hour*2,
		func() (interface{}, error) {
			return client.ComicPicturePageWithQuality(comicId, epOrder, page, quality)
		},
	)
}

func switchLike(comicId string) (string, error) {
	point, err := client.SwitchLike(comicId)
	if err != nil {
		return "", err
	}
	// 更新viewLog里面的favour
	comic_center.ViewComicUpdateLike(comicId, strings.HasPrefix(*point, "un"))
	// 删除缓存
	ComicInfoCleanCache(comicId)
	return *point, nil
}

func switchFavourite(comicId string) (string, error) {
	point, err := client.SwitchFavourite(comicId)
	if err != nil {
		return "", err
	}
	// 更新viewLog里面的favour
	comic_center.ViewComicUpdateFavourite(comicId, strings.HasPrefix(*point, "un"))
	// 删除缓存
	ComicInfoCleanCache(comicId)
	return *point, nil
}

func favouriteComics(params string) (string, error) {
	var paramsStruct struct {
		Sort string `json:"sort"`
		Page int    `json:"page"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	sort := paramsStruct.Sort
	page := paramsStruct.Page
	//
	point, err := client.FavouriteComics(sort, page)
	if err != nil {
		return "", err
	}
	str, err := json.Marshal(point)
	if err != nil {
		return "", err
	}
	return string(str), nil
}

func recommendation(comicId string) (string, error) {
	return cacheable(
		fmt.Sprintf("RECOMMENDATION$%s", comicId),
		time.Hour*2,
		func() (interface{}, error) {
			return client.ComicRecommendation(comicId)
		},
	)
}

func comments(params string) (string, error) {
	var paramsStruct struct {
		ComicId string `json:"comicId"`
		Page    int    `json:"page"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	comicId := paramsStruct.ComicId
	page := paramsStruct.Page
	return cacheable(
		fmt.Sprintf("COMMENTS$%s$%d", comicId, page),
		time.Hour*2,
		func() (interface{}, error) {
			return client.ComicCommentsPage(comicId, page)
		},
	)
}

func commentChildren(params string) (string, error) {
	var paramsStruct struct {
		CommentId string `json:"commentId"`
		Page      int    `json:"page"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	commentId := paramsStruct.CommentId
	page := paramsStruct.Page
	return cacheable(
		fmt.Sprintf("COMMENT_CHILDREN$%s$%d", commentId, page),
		time.Hour*2,
		func() (interface{}, error) {
			return client.CommentChildren(commentId, page)
		},
	)
}

func postComment(params string) (string, error) {
	var paramsStruct struct {
		ComicId string `json:"comicId"`
		Content string `json:"content"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	err := client.PostComment(paramsStruct.ComicId, paramsStruct.Content)
	if err != nil {
		return "", err
	}
	network_cache.RemoveCaches("MY_COMMENTS$%")
	network_cache.RemoveCaches(fmt.Sprintf("COMMENTS$%s$%%", paramsStruct.ComicId))
	return "", nil
}

func postChildComment(params string) (string, error) {
	var paramsStruct struct {
		ComicId string `json:"comicId"`
		CommentId string `json:"commentId"`
		Content   string `json:"content"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	err := client.PostChildComment(paramsStruct.CommentId, paramsStruct.Content)
	if err != nil {
		return "", err
	}
	network_cache.RemoveCaches(fmt.Sprintf("COMMENT_CHILDREN$%s$%%", paramsStruct.CommentId))
	network_cache.RemoveCaches("MY_COMMENTS$%")
	network_cache.RemoveCaches(fmt.Sprintf("COMMENTS$%s$%%", paramsStruct.ComicId))
	return "", nil
}

func myComments(pageStr string) (string, error) {
	page, err := strconv.Atoi(pageStr)
	if err != nil {
		return "", err
	}
	return cacheable(
		fmt.Sprintf("MY_COMMENTS$%d", page),
		time.Hour*2,
		func() (interface{}, error) {
			return client.MyComments(page)
		},
	)
}

func games(pageStr string) (string, error) {
	page, err := strconv.Atoi(pageStr)
	if err != nil {
		return "", err
	}
	return cacheable(
		fmt.Sprintf("GAMES$%d", page),
		time.Hour*2,
		func() (interface{}, error) {
			return client.GamePage(page)
		},
	)
}

func game(gameId string) (string, error) {
	return cacheable(
		fmt.Sprintf("GAME$%s", gameId),
		time.Hour*2,
		func() (interface{}, error) {
			return client.GameInfo(gameId)
		},
	)
}
