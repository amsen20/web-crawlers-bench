package crawler

import gears.async._
import gurl.unsafe.CurlRuntimeContext
import gurl.http.simple._
import gurl.http._

import shared.WebCrawlerBase
import scala.util._

class WebCrawler(using curlRuntimeContext: CurlRuntimeContext)
    extends WebCrawlerBase:
  override def getWebContent(url: String)(using Async): Option[String] =
    CurlRequest(
      SimpleRequest(
        HttpVersion.V1_0,
        HttpMethod.GET,
        List(),
        url,
        "".getBytes()
      )
    )(using curlRuntimeContext) match
      case Success(res) =>
        if res.status != 200 then None
        if !res.headers
            .map(_.map(_.toChar).mkString)
            .map(header =>
              header.contains("content-type") && header.contains("text/html")
            )
            .reduce(_ || _)
        then None
        Some(res.body.map(_.toChar).mkString)
      case Failure(_) => None
