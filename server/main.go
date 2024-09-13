package main

import (
	"crawler/server/server"
	"encoding/json"
	"fmt"
	"os"
)

func readConfig() {
	if len(os.Args) < 2 {
		println("Please provide a file path as an argument.")
		return
	}

	filePath := os.Args[1]
	fmt.Println("File's path: ", filePath)
	file, err := os.Open(filePath)
	if err != nil {
		println("Failed to open the file:", err)
		return
	}
	defer file.Close()

	var config struct {
		BRANCH_FACTOR  int
		CHARS_PER_LINK int
	}

	decoder := json.NewDecoder(file)
	err = decoder.Decode(&config)
	if err != nil {
		println("Failed to decode the JSON file:", err)
		return
	}

	fmt.Println("Config's Branch factor:", config.BRANCH_FACTOR)
	server.BRANCH_FACTOR = config.BRANCH_FACTOR
	fmt.Println("Config's Chars per link:", config.CHARS_PER_LINK)
	server.CHARS_PER_LINK = config.CHARS_PER_LINK
}

func main() {
	readConfig()

	server.StartServer()
}
