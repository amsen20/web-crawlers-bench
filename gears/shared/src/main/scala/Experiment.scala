package shared

import scala.concurrent.ExecutionContext
import scala.concurrent.duration

import gears.async.*
import gears.async.default.given

object Experiment:
  given ExecutionContext = ExecutionContext.global

  def run(crawler: WebCrawlerBase, timeout: Long, maxConnections: Int): Unit =
    val startTime = System.currentTimeMillis()
    Async.blocking:
      Seq(
        Future(AsyncOperations.sleep(timeout)),
        Future(crawler.crawl(START_URL, maxConnections))
      ).awaitFirstWithCancel

    val endTime = System.currentTimeMillis()
    val elapsedTime = endTime - startTime

    println(s"explored=${crawler.successfulExplored.size}")
    println(s"found=${crawler.found.size}")
    println(s"totalChars=${crawler.charsDownloaded}")
    println(s"overheadTime=${elapsedTime - timeout}")

    if DEBUG then
      println("Explored links:")
      crawler.successfulExplored.foreach(println(_))
      // println("Found links:")
      // crawler.found.foreach(println(_))