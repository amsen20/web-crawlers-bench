package crawler

// TODO make it json

val START_URL = "https://en.wikipedia.org/wiki/Scala_(programming_language)"
val LINK_REGEX = """<a\s+(?:[^>]*?\s+)?href=(["'])(.*?)\1""".r
val MAIN_DOMAIN = "wikipedia.org"
val DEBUG = true
