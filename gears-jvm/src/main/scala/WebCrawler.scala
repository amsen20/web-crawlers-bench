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

object WebCrawler {
  val found = mutable.Set[String]()
  val successfulExplored = mutable.Set[String]()
  
  // Only for analysis
  var charsDownloaded = 0

  def exploreLayer(
      seen: Set[String],
      layer: Set[String],
      maxConnections: Int
  )(using Async.Spawn): Set[String] = {
    val nextLayer: mutable.Set[String] = mutable.Set()
    val layerIt = layer.toIterator
    var currentConnections = 0
    val resultFutures: ListBuffer[(Future[Option[String]], String)] =
      ListBuffer()

    def goNext(): Unit =
      if !layerIt.hasNext then return
      val url = layerIt.next()
      resultFutures.addOne(
        (
          Future:
            println("getting url: " + url)
            val ret = jvmInterruptible(getWebContent(url))
            println("done!")
            ret
          ,
          url
        )
      )

    for _ <- 0 until min(maxConnections, layer.size) do goNext()

    while !resultFutures.isEmpty do
      Async.select(
        resultFutures
          .map((f, url) =>
            f.handle(res =>
              res match
                case Success(Some(content)) =>
                  successfulExplored.add(url)
                  charsDownloaded += content.length  

                  val links = UrlUtils.extractLinks(url, content)
                  found ++= links
                  nextLayer ++= links
                  resultFutures.remove(resultFutures.map(_._2).indexOf(url))
                  goNext()
                case Success(None) => ()
                case Failure(e)    => 
                  println(e)
                  e.printStackTrace()
            )
          )
          .toSeq*
      )
    end while

    nextLayer.filter(url => !seen.contains(url) && !layer.contains(url)).toSet
  }

  def crawl(url: String, maxConnections: Int)(using Async.Spawn): Unit = {
    found += url
    val seen = mutable.Set[String]()
    var layer = Set[String](url)

    /* 
      TODO Make the function return a lazy list
      which returns found links one by one,
      then the maxDepth can be removed.
    */
    val maxDepth = if DEBUG then 2 else 1000

    for depth <- 0 until maxDepth do
      val nextLayer = exploreLayer(seen.toSet, layer, maxConnections)
      seen ++= layer
      layer = nextLayer
  }

}

// To make HTTP requests preemptive
def jvmInterruptible[T](fn: => T)(using Async): T =
  val th = Thread.currentThread()
  cancellationScope(() => th.interrupt()):
    try fn
    catch case _: InterruptedException => throw new CancellationException()
