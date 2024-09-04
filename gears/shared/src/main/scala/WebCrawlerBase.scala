package shared

import scala.concurrent.ExecutionContext
import scala.io.Source
import scala.util._
import scala.math.min
import scala.concurrent.duration

import gears.async.*
import gears.async.default.given
import scala.compiletime.ops.double
import gears.async.Future.MutableCollector
import scala.collection.immutable.HashSet
import scala.annotation.tailrec
import scala.collection.mutable

class CollectorWithSize[T] extends MutableCollector[T]():
  var size = 0
  inline def addOne(future: Future[T]): Unit =
    addFuture(future)
    size += 1

  def next()(using Async) =
    assert(size > 0)
    size -= 1
    results.read().right.get

@volatile var counter = 0

abstract class WebCrawlerBase {
  val found = mutable.HashSet[String]()
  val successfulExplored = mutable.HashSet[String]()

  // Only for analysis
  @volatile var charsDownloaded = 0

  def getWebContent(url: String)(using Async): Option[String] = ???

  def exploreLayer(
      seen: HashSet[String],
      layer: List[String],
      maxConnections: Int
  )(using Async): List[String] = Async.group {
    val nextLayer = mutable.ListBuffer[String]()
    @volatile var layerInd = 0
    val layerIt = layer.iterator
    val layerLength = layer.length
    @volatile var currentConnections = 0
    val resultFutures = CollectorWithSize[(Option[String], String)]()

    def goNext(): Unit =
      val url = layerIt.next()
      layerInd += 1
      resultFutures.addOne(
        Future:
          val ret = getWebContent(url)
          (ret, url)
      )

    for _ <- 0 until min(maxConnections, layerLength) do goNext()

    while resultFutures.size > 0 do
      val res = resultFutures.next().awaitResult
      res match
        case Success(Some(content), url) =>
          successfulExplored += url
          charsDownloaded += content.length

          val links = UrlUtils.extractLinks(url, content)
          found ++= links
          nextLayer ++= links

          if layerInd < layerLength then goNext()
        case Success(None, _) => ()
        case Failure(e) =>
          e.printStackTrace()
    end while

    nextLayer.filterInPlace(!seen.contains(_)).toList
  }

  @tailrec
  final def crawlRecursive(
      seen: HashSet[String],
      layer: List[String],
      maxConnections: Int,
      depth: Int
  )(using Async): Unit =
    if depth != 0 then
      val nextLayer = exploreLayer(seen, layer, maxConnections)
      crawlRecursive(
        seen ++ nextLayer,
        nextLayer,
        maxConnections,
        depth - 1
      )

  def crawl(url: String, maxConnections: Int)(using Async): Unit = {
    /*
      TODO Make the function return a lazy list
      which returns found links one by one,
      then the maxDepth can be removed.
     */
    val maxDepth = 100000000 // if DEBUG then 2 else 1000

    found.add(url)

    crawlRecursive(HashSet.empty, List(url), maxConnections, maxDepth)
  }
}
