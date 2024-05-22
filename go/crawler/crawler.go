package crawler

import (
	"bytes"
	"context"
	"io"
	"net/http"
	"sync"
	"webcrawler/utils"
)

type WebCrawler struct {
	Found              map[string]struct{}
	SuccessfulExplored map[string]struct{}
	CharsDownloaded    int
}

func New() *WebCrawler {
	return &WebCrawler{
		Found:              make(map[string]struct{}),
		SuccessfulExplored: make(map[string]struct{}),
		CharsDownloaded:    0,
	}
}

func (w *WebCrawler) getWebContent(ctx context.Context, url string) (string, error) {
	resp, err := http.Get(url)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	buf := new(bytes.Buffer)
	done := make(chan struct{})
	go func() {
		defer close(done)
		_, _ = io.Copy(buf, resp.Body)
	}()

	select {
	case <-ctx.Done():
		return "", ctx.Err()
	case <-done:
		body := buf.String()
		return body, nil
	}
}

func (w *WebCrawler) exploreLayer(ctx context.Context, layer map[string]struct{}, maxConnections int) map[string]struct{} {
	var wg sync.WaitGroup
	mu := sync.Mutex{}
	nextLayer := make(map[string]struct{})

	tokenChan := make(chan struct{}, maxConnections)
	for i := 0; i < maxConnections; i++ {
		tokenChan <- struct{}{}
	}

	for url := range layer {
		select {
		case <-ctx.Done():
			return nil
		case <-tokenChan:
		}

		wg.Add(1)
		go func(url string) {
			defer wg.Done()
			defer func() { tokenChan <- struct{}{} }()

			content, err := w.getWebContent(ctx, url)

			if err != nil {
				// fmt.Println(err)
				return
			}

			select {
			case <-ctx.Done():
				return
			default:
			}
			mu.Lock()
			defer mu.Unlock()

			w.SuccessfulExplored[url] = struct{}{}
			w.CharsDownloaded += len(content)

			links, err := utils.ExtractLinks(url, content)
			if err != nil {
				// fmt.Println(err)
				return
			}

			for _, link := range links {
				if _, ok := w.Found[link]; ok {
					continue
				}
				select {
				case <-ctx.Done():
					return
				default:
				}

				w.Found[link] = struct{}{}
				nextLayer[link] = struct{}{}
			}
		}(url)
	}

	wg.Wait()

	return nextLayer
}

func (w *WebCrawler) Crawl(ctx context.Context, url string, maxConnections int) {
	w.Found[url] = struct{}{}
	layer := map[string]struct{}{url: {}}

	maxDepth := 1000

	for depth := 0; depth < maxDepth; depth++ {
		select {
		case <-ctx.Done():
			return
		default:
		}

		nextLayer := w.exploreLayer(ctx, layer, maxConnections)
		layer = nextLayer
	}
}
