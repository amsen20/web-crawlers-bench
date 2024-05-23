package shared

object UrlUtils {
  def isValidURL(url: String): Boolean =
    val prefix = url.startsWith("http://") || url.startsWith("https://")
    val noParams = !url.contains("?")
    val noColon = true // !url.slice(url.indexOf("://") + 3, url.length).contains(":")
    val onMainDomain = url.contains(MAIN_DOMAIN)
    prefix && noParams && noColon && onMainDomain

  def ifValid(url: String): Option[String] =
    if isValidURL(url) then Some(url) else None

  def getBaseURL(url: String): String =
    val idx = url.indexOf("/", url.indexOf("://") + 3)
    url.substring(0, idx)

  def removeParams(url: String): String =
    val index = url.indexOf('?')
    if index != -1 then url.substring(0, index) else url

  def cleanURL(url: String, baseURL: String): Option[String] =
    val noParamURL = removeParams(url)

    if url.startsWith("/") then
      // relative URL
      ifValid(baseURL + noParamURL)
    else
      // absolute URL
      ifValid(noParamURL)

  def extractLinks(url: String, content: String): Set[String] =
    val links = LINK_REGEX
      .findAllMatchIn(
        content
      )
      .map(matched => if matched.group(1).nonEmpty then matched.group(1) else matched.group(2))
      .toList

    val baseURL = getBaseURL(url)
    val targetLinks = links
      .map(cleanURL(_, baseURL))
      .foldLeft(List[String]())((acc, x) =>
        x match {
          case Some(value) => acc :+ value
          case None        => acc
        }
      ).toSet
    targetLinks
}
