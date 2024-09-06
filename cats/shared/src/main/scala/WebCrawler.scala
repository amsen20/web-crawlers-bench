package shared

import scala.concurrent.ExecutionContext
import scala.io.Source
import scala.util._
import scala.math.min
import scala.concurrent.duration
import scala.compiletime.ops.double

import cats.effect._
import cats.effect.std.Console
import cats.effect.std.Queue
import cats.syntax.all._
import org.http4s.client.Client
import scala.collection.immutable.HashSet

class WebCrawler(client: Client[IO]) {
  // TODO: change this to be val and passed by the constructor
  var foundR: Ref[IO, HashSet[String]] = null
  var successfulExploredR: Ref[IO, HashSet[String]] = null
  var charsDownloadedR: Ref[IO, Int] = null

  def initRefs(
      foundR: Ref[IO, HashSet[String]],
      successfulExploredR: Ref[IO, HashSet[String]],
      charsDownloadedR: Ref[IO, Int]
  ) =
    this.foundR = foundR
    this.successfulExploredR = successfulExploredR
    this.charsDownloadedR = charsDownloadedR

  def getWebContent(url: String): IO[Option[String]] =
    client.get(url)(response =>
      if response.status.isSuccess then
        response.bodyText.compile.fold("")(_ + _).map(Some(_))
      else IO.pure(None)
    )

  def exploreUrl(
      url: String,
      nextLayerR: Ref[IO, HashSet[String]]
  ): IO[Unit] =
    for {
      content <- getWebContent(url)
      _ <- content match
        case Some(content) =>
          for {
            _ <- successfulExploredR.update(_ + url)
            _ <- charsDownloadedR.update(_ + content.length)
            links = UrlUtils.extractLinks(url, content)
            _ <- nextLayerR.update(_ ++ links)
            _ <- foundR.update(_ ++ links)
          } yield ()
        case None =>
          IO.unit
    } yield ()

  def exploreLayer(
      seen: HashSet[String],
      layer: Array[String],
      maxConnections: Int
  ): IO[Array[String]] =
    for {
      nextLayerR <- Ref[IO].of(HashSet[String]())
      tokenChan <- Queue.unbounded[IO, Unit]

      // add tokens
      _ <- List.range(0, maxConnections).map(_ => tokenChan.offer(())).sequence_

      explorers = layer.map(url =>
        for {
          _ <- tokenChan.take
          _ <- exploreUrl(url, nextLayerR)
          _ <- tokenChan.offer(())
        } yield ()
      )
      /*
       * It starts the explorers for all the layer, but the explorers
       * awaits for the token and then start, so does it matter
       * if we start all of them at once or start them one by one when the token is available?
       */
      _ <- explorers.toList.parSequence.handleError(t =>
        Console[IO].errorln(s"Error caught: ${t.getMessage}")
      )

      // get tokens meaning the process is finished
      _ <- List.range(0, maxConnections).map(_ => tokenChan.take).sequence_
      nextLayer <- nextLayerR.get
    } yield (nextLayer -- seen)
      .toArray

  def crawlRecursive(
      seen: HashSet[String],
      layer: Array[String],
      maxConnections: Int,
      depth: Int
  ): IO[Unit] =
    if depth == 0 then IO.unit
    else
      for {
        nextLayer <- exploreLayer(seen, layer, maxConnections)
        _ <- crawlRecursive(
          seen ++ nextLayer,
          nextLayer,
          maxConnections,
          depth - 1
        )
      } yield ()

  def crawl(url: String, maxConnections: Int): IO[Unit] = {
    /*
      TODO Make the function return a lazy list
      which returns found links one by one,
      then the maxDepth can be removed.
     */
    val maxDepth = if DEBUG then 2 else 1000

    for {
      _ <- foundR.set(HashSet[String](url))
      _ <- crawlRecursive(HashSet.empty, Array(url), maxConnections, maxDepth)
    } yield ()
  }
}
