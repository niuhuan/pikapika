// 透传Client的功能并增加缓存

package pikapika

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	source "github.com/niuhuan/pica-go"
	"golang.org/x/net/proxy"
	"net"
	"net/http"
	"net/url"
	"pikapika/pikapika/database/comic_center"
	"pikapika/pikapika/database/network_cache"
	"pikapika/pikapika/database/properties"
	"regexp"
	"time"
)

import (
	"context"
	"strconv"
	"strings"
)

func InitClient() {
	client.Timeout = time.Second * 60
	switchAddress, _ = properties.LoadIntProperty("switchAddress", 1)
	imageSwitchAddress, _ = properties.LoadIntProperty("imageSwitchAddress", 1)
	proxy, _ := properties.LoadProxy()
	changeProxyUrl(proxy)
}

var client = source.Client{}
var dialer = &net.Dialer{
	Timeout:   30 * time.Second,
	KeepAlive: 30 * time.Second,
}

// SwitchAddress
var switchAddresses = map[int]string{
	1: "172.67.7.24:443",
	2: "104.20.180.50:443",
	3: "172.67.208.169:443",
}

var switchAddress = 1
var switchAddressPattern, _ = regexp.Compile("^.+picacomic\\.com:\\d+$")

func changeProxyUrl(urlStr string) bool {
	if urlStr == "" {
		client.Transport = &http.Transport{
			TLSHandshakeTimeout:   time.Second * 10,
			ExpectContinueTimeout: time.Second * 10,
			ResponseHeaderTimeout: time.Second * 10,
			IdleConnTimeout:       time.Second * 10,
			DialContext: func(ctx context.Context, network, addr string) (net.Conn, error) {
				if sAddr, ok := switchAddresses[switchAddress]; ok {
					addr = sAddr
				}
				return dialer.DialContext(ctx, network, addr)
			},
		}
		imageHttpClient.Transport = &http.Transport{
			TLSHandshakeTimeout:   time.Second * 10,
			ExpectContinueTimeout: time.Second * 10,
			ResponseHeaderTimeout: time.Second * 10,
			IdleConnTimeout:       time.Second * 10,
			DialContext: func(ctx context.Context, network, addr string) (net.Conn, error) {
				return dialer.DialContext(ctx, network, addr)
			},
		}
		return false
	}
	client.Transport = &http.Transport{
		TLSHandshakeTimeout:   time.Second * 10,
		ExpectContinueTimeout: time.Second * 10,
		ResponseHeaderTimeout: time.Second * 10,
		IdleConnTimeout:       time.Second * 10,
		DialContext: func(ctx context.Context, network, addr string) (net.Conn, error) {
			proxyUrl, err := url.Parse(urlStr)
			if err != nil {
				return nil, err
			}
			proxy, err := proxy.FromURL(proxyUrl, proxy.Direct)
			if err != nil {
				return nil, err
			}
			if sAddr, ok := switchAddresses[switchAddress]; ok {
				addr = sAddr
			}
			return proxy.Dial(network, addr)
		},
	}
	imageHttpClient.Transport = &http.Transport{
		TLSHandshakeTimeout:   time.Second * 10,
		ExpectContinueTimeout: time.Second * 10,
		ResponseHeaderTimeout: time.Second * 10,
		IdleConnTimeout:       time.Second * 10,
		DialContext: func(ctx context.Context, network, addr string) (net.Conn, error) {
			proxyUrl, err := url.Parse(urlStr)
			if err != nil {
				return nil, err
			}
			proxy, err := proxy.FromURL(proxyUrl, proxy.Direct)
			if err != nil {
				return nil, err
			}
			return proxy.Dial(network, addr)
		},
	}
	return true
}

func userProfile() (string, error) {
	return serialize(client.UserProfile())
}

func punchIn() (string, error) {
	return serialize(client.PunchIn())
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
		ComicId   string `json:"comicId"`
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

func postGameChildComment(params string) (string, error) {
	var paramsStruct struct {
		GameId    string `json:"gameId"`
		CommentId string `json:"commentId"`
		Content   string `json:"content"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	err := client.PostChildComment(paramsStruct.CommentId, paramsStruct.Content)
	if err != nil {
		return "", err
	}
	network_cache.RemoveCaches(fmt.Sprintf("GAME_COMMENT_CHILDREN$%s$%%", paramsStruct.CommentId))
	network_cache.RemoveCaches("MY_COMMENTS$%")
	network_cache.RemoveCaches(fmt.Sprintf("GAME_COMMENTS$%s$%%", paramsStruct.GameId))
	return "", nil
}

func switchLikeComment(params string) (string, error) {
	var paramsStruct struct {
		CommentId string `json:"commentId"`
		ComicId   string `json:"comicId"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	rsp, err := client.SwitchLikeComment(paramsStruct.CommentId)
	if err != nil {
		return "", err
	}
	network_cache.RemoveCaches(fmt.Sprintf("COMMENT_CHILDREN$%s$%%", paramsStruct.CommentId))
	network_cache.RemoveCaches("MY_COMMENTS$%")
	network_cache.RemoveCaches(fmt.Sprintf("COMMENTS$%s$%%", paramsStruct.ComicId))
	return *rsp, nil
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

func gameComments(params string) (string, error) {
	var paramsStruct struct {
		GameId string `json:"gameId"`
		Page   int    `json:"page"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	gameId := paramsStruct.GameId
	page := paramsStruct.Page
	return cacheable(
		fmt.Sprintf("GAME_COMMENTS$%s$%d", gameId, page),
		time.Hour*2,
		func() (interface{}, error) {
			return client.GameCommentsPage(gameId, page)
		},
	)
}

func postGameComment(params string) (string, error) {
	var paramsStruct struct {
		GameId  string `json:"gameId"`
		Content string `json:"content"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	err := client.PostGameComment(paramsStruct.GameId, paramsStruct.Content)
	if err != nil {
		return "", err
	}
	network_cache.RemoveCaches("MY_COMMENTS$%")
	network_cache.RemoveCaches(fmt.Sprintf("GAME_COMMENTS$%s$%%", paramsStruct.GameId))
	return "", nil
}

func gameCommentChildren(params string) (string, error) {
	var paramsStruct struct {
		CommentId string `json:"commentId"`
		Page      int    `json:"page"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	commentId := paramsStruct.CommentId
	page := paramsStruct.Page
	return cacheable(
		fmt.Sprintf("GAME_COMMENT_CHILDREN$%s$%d", commentId, page),
		time.Hour*2,
		func() (interface{}, error) {
			return client.GameCommentChildren(commentId, page)
		},
	)
}

func switchLikeGameComment(params string) (string, error) {
	var paramsStruct struct {
		CommentId string `json:"commentId"`
		GameId    string `json:"gameId"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	rsp, err := client.SwitchLikeComment(paramsStruct.CommentId)
	if err != nil {
		return "", err
	}
	network_cache.RemoveCaches(fmt.Sprintf("GAME_COMMENT_CHILDREN$%s$%%", paramsStruct.CommentId))
	network_cache.RemoveCaches("MY_COMMENTS$%")
	network_cache.RemoveCaches(fmt.Sprintf("GAME_COMMENTS$%s$%%", paramsStruct.GameId))
	return *rsp, nil
}

func updatePassword(params string) (string, error) {
	var paramsStruct struct {
		OldPassword string `json:"oldPassword"`
		NewPassword string `json:"newPassword"`
	}
	err := json.Unmarshal([]byte(params), &paramsStruct)
	if err != nil {
		return "", err
	}
	err = client.UpdatePassword(paramsStruct.OldPassword, paramsStruct.NewPassword)
	if err != nil {
		return "", err
	}
	setPassword(paramsStruct.NewPassword)
	return "", nil
}

func updateSlogan(slogan string) (string, error) {
	return "", client.UpdateSlogan(slogan)
}

func updateAvatar(avatarBase64 string) (string, error) {
	buff, err := base64.StdEncoding.DecodeString(avatarBase64)
	if err != nil {
		return "", err
	}
	return "", client.UpdateAvatar(buff)
}
