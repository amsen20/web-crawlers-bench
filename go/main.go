package main

import (
	"flag"
	"fmt"
	"time"
	"webcrawler/crawler"
)

func main() {
	// debug.SetGCPercent(-1)
	timeout := flag.Int("timeout", 0, "duration of crawling")
	maxConnections := flag.Int("max-connections", 0, "maximum number of parallel connections")
	flag.Parse()

	if timeout == nil || maxConnections == nil {
		panic("timeout and maxConnections are required")
	}
	wc := crawler.New()
	duration, err := time.ParseDuration(fmt.Sprintf("%dms", *timeout))
	if err != nil {
		panic(err)
	}

	crawler.RunExperiment(wc, duration, *maxConnections)
}
