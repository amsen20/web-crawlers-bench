package server

import "fmt"

func generateTemplateContent() string {
	var content string
	for i := 0; i < BRANCH_FACTOR; i++ {
		content += "<p>\n"
		for j := 0; j < CHARS_PER_LINK/len(MSG); j++ {
			content += MSG
		}
		content += "</p>\n"
		content += `<a href="/page/%d">Page %d</a>`
		content += "\n"
	}

	return content
}

func generateContent(seed int64, templateContent string) string {
	numbers := make([]interface{}, 0)

	for i := 0; i < BRANCH_FACTOR; i++ {
		pageId := (seed * int64(BRANCH_FACTOR)) + int64(i)
		numbers = append(numbers, pageId, pageId)
	}

	return fmt.Sprintf(templateContent, numbers...)
}
