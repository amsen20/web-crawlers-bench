package crawler

import scala.concurrent.ExecutionContext
import scala.collection.mutable
import scala.io.Source
import scala.util._
import scala.math.min
import scala.concurrent.duration

import gears.async.*
import gears.async.default.given
import scala.collection.mutable.ListBuffer
import scala.compiletime.ops.double
import gears.async.Future.MutableCollector

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
