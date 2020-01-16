package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"github.com/adeynack/finances-service-go/pkg/model/api"
	"github.com/go-http-utils/headers"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strings"
)

var (
	serviceURL string
	devUser    string
)

func main() {
	flag.StringVar(
		&serviceURL,
		"url",
		"http://localhost:3000",
		"the URL of the Finances Service",
	)
	flag.StringVar(
		&devUser,
		"dev-user",
		"",
		"the user ID to pass as a header to the service (development mode)",
	)
	flag.Parse()

	fmt.Printf("Using service at %s\n", serviceURL)
	if devUser != "" {
		fmt.Printf("Authentication in DEV mode with %s\n", devUser)
	}

	r := bufio.NewScanner(os.Stdin)
	for {
		print("[] > ")
		if r.Scan() {
			if r.Err() != nil {
				log.Fatalln(r.Err())
			} else {
				if !interpretCommand(strings.Split(r.Text(), " ")) {
					break
				}
			}
		}
	}
}

func interpretCommand(cmd []string) bool {
	switch cmd[0] {
	case "quit":
		return false
	case "books":
		listBooks(cmd[1:])
	case "dev-user":
		setDevUser(cmd[1:])
	}
	return true
}

func setDevUser(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: dev-user <user_id>")
		return
	}
	devUser = args[0]
	fmt.Println("set development user to", devUser)
}

func authorize(req *http.Request) {
	if devUser != "" {
		req.Header.Add(headers.Authorization, fmt.Sprintf("Bearer DEV %s", devUser))
	}
}

func listBooks(args []string) {
	url := fmt.Sprintf("%s/books", serviceURL)
	if len(args) > 0 && args[0] == "all" {
		url += "?list-all=true"
	}
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		fmt.Println("error creating HTTP request:", err)
		return
	}
	authorize(req)
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		fmt.Println("error sending HTTP request:", err)
		return
	}
	if resp.StatusCode >= 300 {
		fmt.Println("response status code:", resp.StatusCode)
		bytes, _ := ioutil.ReadAll(resp.Body)
		fmt.Println(string(bytes))
		return
	}
	var bookList api.BookList
	if err := json.NewDecoder(resp.Body).Decode(&bookList); err != nil {
		fmt.Println("error decoding response body", err)
		return
	}
	fmt.Printf("| %6s | %-20s | %-8s |\n", "ID", "NAME", "OWNER ID")
	for _, book := range bookList.Items {
		fmt.Printf("| %6d | %-20s | %8d |\n", book.ID, book.Name, book.OwnerID)
	}
}
