package controller

import (
	"errors"
	"fmt"
	"github.com/PuerkitoBio/goquery"
	"net/http"
	"regexp"
	"time"
)

var downloadGameUrlPattern, _ = regexp.Compile("^https://game\\.eroge\\.xyz/hhh\\.php\\?id=\\d+$")

func downloadGame(url string) (string, error) {
	if downloadGameUrlPattern.MatchString(url) {
		return cacheable(fmt.Sprintf("GAME_PAGE$%s", url), time.Hour*1000, func() (interface{}, error) {
			req, err := http.NewRequest("GET", url, nil)
			if err != nil {
				return nil, err
			}
			req.Header.Set("user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36")
			rsp, err := client.Do(req)
			if err != nil {
				return nil, err
			}
			defer rsp.Body.Close()
			doc, err := goquery.NewDocumentFromReader(rsp.Body)
			if err != nil {
				return nil, err
			}
			find := doc.Find("a.layui-btn")
			list := make([]string, find.Size())
			find.Each(func(i int, selection *goquery.Selection) {
				list[i] = selection.AttrOr("href", "")
			})
			return list, nil
		})
	}
	return "", errors.New("not support url")
}
