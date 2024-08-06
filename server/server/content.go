package server

import "fmt"

func generateContent(seed int64) string {
	var content string
	for i := 0; i < BRANCH_FACTOR; i++ {
		content += "<p>\n"
		for j := 0; j < CHARS_PER_LINK/len(MSG); j++ {
			content += MSG
		}
		content += "</p>\n"

		pageId := (seed * BRANCH_FACTOR) + int64(i)

		content += `<a href="/page/`
		content += fmt.Sprintf("%d", pageId)
		content += `">`
		content += fmt.Sprintf("Page %d", pageId)
		content += "</a>\n"
	}

	return content
}
