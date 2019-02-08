package main

import (
	"bufio"
	"fmt"
	"net/http"
	"os"
)

const CONNECT_URL = "localhost" // 接続先
const CONNECT_PORT = "48080"    // ポート
const AGREE = "100"             // 賛成
const OPPOSITE = "200"          // 反対
const NEUTRAL = "300"           // 中立

func HttpPost(url string, key1 string, value1 string, key2 string, value2 string) error {
	var baseurl string
	baseurl = url + "?" + key1 + "=" + value1 + "&" + key2 + "=" + value2

	fmt.Println(baseurl)

	resp, err := http.Get(baseurl)
	if err != nil {
		fmt.Println(err)
		return err
	}
	defer resp.Body.Close()

	return err
}

func ScanStdin() string {
	stdin := bufio.NewScanner(os.Stdin)
	stdin.Scan()
	return stdin.Text()
}

func Send(user string) {
	sData := ScanStdin()

	if sData == AGREE {
		sData = "agree"
	} else if sData == OPPOSITE {
		sData = "opposite"
	} else if sData == NEUTRAL {
		sData = "neutral"
	}
	fmt.Println("意見: " + sData)

	err := HttpPost("http://"+CONNECT_URL+":"+CONNECT_PORT+"/insert", "user", user, "opi", sData)

	if err != nil {
		fmt.Print("Can't Post")
	}

	//return err
}

func main() {
	fmt.Println("Start")

	user := ScanStdin()
	fmt.Println("ユーザ: " + user)

	Send(user)
	// fmt.Println(userID)

}
