package controller

import (
	"net"
	"strings"
)

func clientIpSet() (string, error) {
	address, err := net.InterfaceAddrs()
	if err != nil {
		return "", err
	}
	ipSet := make([]string, 0)
	for _, address := range address {
		// 检查ip地址判断是否回环地址
		if ipNet, ok := address.(*net.IPNet); ok && !ipNet.IP.IsLoopback() {
			if ipNet.IP.To4() != nil {
				ipSet = append(ipSet, ipNet.IP.To4().String())
			}
		}
	}
	return strings.Join(ipSet, ","), nil
}
