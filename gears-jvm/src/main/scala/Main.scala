package crawler

import scala.concurrent.ExecutionContext
import scala.concurrent.duration

import gears.async.*
import gears.async.default.given

given ExecutionContext = ExecutionContext.global

@main def run(timeout: Long, maxConnections: Int): Unit =
  val startTime = System.currentTimeMillis()

  Async.blocking:
    Seq(
      Future(AsyncOperations.sleep(timeout)),
      Future(WebCrawler.crawl(START_URL, maxConnections))
    ).awaitFirstWithCancel

  val endTime = System.currentTimeMillis()
  val elapsedTime = endTime - startTime

  println(s"explored=${WebCrawler.successfulExplored.size}")
  println(s"found=${WebCrawler.found.size}")
  println(s"totalChars=${WebCrawler.charsDownloaded}")
  println(s"overheadTime=${elapsedTime - timeout}")

  if DEBUG then
    println("Explored links:")
    WebCrawler.successfulExplored.foreach(println(_))
    // println("Found links:")
    // WebCrawler.found.foreach(println(_))
