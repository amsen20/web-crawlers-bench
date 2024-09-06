package crawler

import shared.Experiment
import shared.WebCrawler
import cats.effect._
import org.http4s.curl.CurlApp

object Main extends CurlApp {
  def run(args: List[String]): IO[ExitCode] = {
    val crawler = new WebCrawler(curlClient)
    if (args.length < 2) {
      println("Not enough arguments")
      println("usage: timeout max-connections")
      return IO.pure(ExitCode.Success)
    }
    for {
      _ <- IO(())
      timeout = args(0).toInt
      maxConnections = args(1).toInt
      _ <- Experiment.run(crawler, timeout, maxConnections)
    } yield ExitCode.Success
  }
}
