package crawler

import (
	"context"
	"fmt"
	"time"
	"webcrawler/utils"
)

func RunExperiment(crawler *WebCrawler, timeout time.Duration, maxConnections int) {
	startTime := time.Now()

	ctx, cancel := context.WithDeadline(context.Background(), startTime.Add(timeout))

	crawler.Crawl(ctx, utils.START_URL, maxConnections)
	cancel()

	elapsedTime := time.Since(startTime)

	fmt.Printf("explored=%d\n", len(crawler.SuccessfulExplored))
	fmt.Printf("found=%d\n", len(crawler.Found))
	fmt.Printf("totalChars=%d\n", crawler.CharsDownloaded)
	fmt.Printf("overheadTime=%d\n", (elapsedTime-timeout).Milliseconds())

	if utils.DEBUG {
		fmt.Println("Explored links:")
		for link := range crawler.SuccessfulExplored {
			fmt.Println(link)
		}

		fmt.Println("Found links:")
		for link := range crawler.Found {
			fmt.Println(link)
		}
	}
}
