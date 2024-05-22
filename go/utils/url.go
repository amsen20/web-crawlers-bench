package utils

import (
	"fmt"
	"net/url"
	"strings"
)

func isValidURL(targetUrl *url.URL) bool {
	prefix := targetUrl.Scheme == "http" || targetUrl.Scheme == "https"
	noParams := targetUrl.RawQuery == ""
	noFragment := targetUrl.Fragment == ""
	noUser := targetUrl.User == nil
	noColon := !strings.Contains(targetUrl.Host, ":") || !strings.Contains(targetUrl.Path, ":")
	onMainDomain := strings.Contains(targetUrl.Host, MAIN_DOMAIN)

	return prefix && noParams && noColon && onMainDomain && noFragment && noUser
}

func cleanURL(targetUrl string, currentUrl *url.URL) string {
	parsedURL, err := url.Parse(targetUrl)
	if err != nil {
		return ""
	}

	if parsedURL.Host == "" {
		// relative
		parsedURL.Scheme = currentUrl.Scheme
		parsedURL.Host = currentUrl.Host
	} else {
		// absolute
		if parsedURL.Scheme != currentUrl.Scheme {
			return ""
		}
		if parsedURL.Host != currentUrl.Host {
			return ""
		}
	}

	parsedURL.User = nil
	parsedURL.RawQuery = ""
	parsedURL.Fragment = ""

	if isValidURL(parsedURL) {
		return parsedURL.String()
	} else {
		return ""
	}
}

func ExtractLinks(targetUrl, content string) ([]string, error) {
	parsedURL, err := url.Parse(targetUrl)
	if err != nil {
		println("Error parsing URL: ", err.Error())
		return nil, fmt.Errorf("couldn't parse the target url %s", targetUrl)
	}

	matches := LINK_REGEX.FindAllStringSubmatch(content, -1)
	links := []string{}
	for _, match := range matches {
		if match[1] != "" {
			links = append(links, match[1])
		} else if match[2] != "" {
			links = append(links, match[2])
		}
	}

	targetLinksSet := make(map[string]struct{})
	for _, link := range links {
		cleaned := cleanURL(link, parsedURL)
		if cleaned != "" {
			targetLinksSet[cleaned] = struct{}{}
		}
	}

	targetLinks := make([]string, len(targetLinksSet))
	index := 0
	for link := range targetLinksSet {
		targetLinks[index] = link
		index += 1
	}

	return targetLinks, nil
}
