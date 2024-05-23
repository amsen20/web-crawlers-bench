package utils

import "regexp"

const START_URL = "http://localhost:8080/page/1"
const MAIN_DOMAIN = "localhost:8080"
const DEBUG = false

var LINK_REGEX = regexp.MustCompile(`<a\s+(?:[^>]*?\s+)?href="([^"]*)"|<a\s+(?:[^>]*?\s+)?href='([^']*)'`)
