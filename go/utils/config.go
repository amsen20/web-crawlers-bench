package utils

import "regexp"

const START_URL = "https://en.wikipedia.org/wiki/Scala_(programming_language)"
const MAIN_DOMAIN = "wikipedia.org"
const DEBUG = false

var LINK_REGEX = regexp.MustCompile(`<a\s+(?:[^>]*?\s+)?href="([^"]*)"|<a\s+(?:[^>]*?\s+)?href='([^']*)'`)
