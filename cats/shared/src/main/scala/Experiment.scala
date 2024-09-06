package shared

import cats.effect._
import scala.concurrent.duration._
import java.sql.Time
import java.util.concurrent.TimeoutException
import scala.collection.immutable.HashSet

object Experiment {
  def run(
      crawler: WebCrawler,
      timeout: Int,
      maxConnections: Int
  ): IO[Unit] =
    for {

      successfulExploredR <- Ref.of[IO, HashSet[String]](HashSet.empty)
      foundR <- Ref.of[IO, HashSet[String]](HashSet.empty)
      charsDownloadedR <- Ref.of[IO, Int](0)
      _ <- IO(crawler.initRefs(foundR, successfulExploredR, charsDownloadedR))

      startTime = System.currentTimeMillis()
      _ <- crawler
        .crawl(START_URL, maxConnections)
        .timeout(FiniteDuration(timeout, "ms"))
        .handleErrorWith(e =>
          e match
            case _: TimeoutException => IO(())
            case e: Throwable =>
              IO(println(s"Task failed with $e"))
        )
      endTime = System.currentTimeMillis()

      successfulExplored <- successfulExploredR.get
      found <- foundR.get
      charsDownloaded <- charsDownloadedR.get
    } yield
      println(s"explored=${successfulExplored.size}")
      println(s"found=${found.size}")
      println(s"totalChars=${charsDownloaded}")
      val elapsedTime = endTime - startTime
      println(s"overheadTime=${elapsedTime - timeout}")

      if DEBUG then
        println("Explored links:")
        successfulExplored.foreach(println(_))
        println("Found links:")
        found.foreach(println(_))
}
