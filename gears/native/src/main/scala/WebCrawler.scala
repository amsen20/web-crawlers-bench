package crawler

import gears.async._
import purl.unsafe.CurlRuntimeContext
import pollerBear.runtime.ActivePoller
import purl.http.simple._
import purl.http._

import shared.WebCrawlerBase
import scala.util._

class WebCrawler(using curlRuntimeContext: CurlRuntimeContext, p: ActivePoller)
    extends WebCrawlerBase:
  override def getWebContent(url: String)(using Async): Option[String] =
    gearsPurl.request(
      SimpleRequest(
        HttpVersion.V1_1,
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
