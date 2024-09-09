package crawler

import gears.async.*

import shared.WebCrawlerBase

class WebCrawler extends WebCrawlerBase:
  override def getWebContent(url: String)(using Async): Option[String] =
    jvmInterruptible:
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

// To make HTTP requests preemptive
def jvmInterruptible[T](fn: => T)(using Async): T =
  val th = Thread.currentThread()
  cancellationScope(() => th.interrupt()):
    try fn
    catch case _: InterruptedException => throw new CancellationException()
