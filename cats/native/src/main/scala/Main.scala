package crawler

import shared.Experiment
import shared.WebCrawler
import cats.effect._
import org.http4s.curl.CurlApp

object Main extends CurlApp {
  def run(args: List[String]): IO[ExitCode] = {
    val crawler = new WebCrawler(curlClient)
    for {
      _ <- IO.raiseWhen(args.length < 2)(
        new IllegalArgumentException("usage: timeout max-connections")
      )
      timeout = args(0).toInt
      maxConnections = args(1).toInt
      _ <- Experiment.run(crawler, timeout, maxConnections)
    } yield ExitCode.Success
  }
}
