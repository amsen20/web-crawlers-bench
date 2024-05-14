package crawler

import scala.concurrent.ExecutionContext
import scala.concurrent.duration

import gears.async.*
import gears.async.default.given

given ExecutionContext = ExecutionContext.global

@main def run(): Unit =
  val timeout = 1 // read it from arguments
  val maxConnections = 1 // read it from arguments
  Async.blocking:
    withTimeout(duration.FiniteDuration(timeout, duration.MILLISECONDS))(
      WebCrawler.crawl(START_URL, maxConnections)
    )
  
  println(s"Found ${WebCrawler.found.size} unique links")
  println(s"Explored ${WebCrawler.successfulExplored.size} unique links successfully")
  println(s"Chars downloaded: ${WebCrawler.charsDownloaded}")
  
  if DEBUG then
    println("Explored links:")
    WebCrawler.successfulExplored.foreach(println(_))
    // println("Found links:")
    // WebCrawler.found.foreach(println(_))
