package crawler

def getWebContent(url: String): Option[String] =
  try {
    val res = requests.get(url)
    if res.statusCode != 200 then None
    if !res
        .headers("content-type")
        .map(_.contains("text/html"))
        .reduce(_ || _)
    then None
    Some(res.text())
  } catch {
    case e: requests.RequestsException => None
  }
