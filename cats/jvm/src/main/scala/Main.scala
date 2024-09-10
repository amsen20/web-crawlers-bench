package crawler

import shared.Experiment
import shared.WebCrawler
import cats.effect._
import org.http4s.ember.client.EmberClientBuilder

object Main extends IOApp {
  def run(args: List[String]): IO[ExitCode] = {
    EmberClientBuilder
      .default[IO]
      .build
      .use { client =>
        val crawler = new WebCrawler(client)
        for {
          _ <- IO.raiseWhen(args.length < 2)(
            new IllegalArgumentException("usage: timeout max-connections")
          )
          timeout = args(0).toInt
          maxConnections = args(1).toInt
          _ <- Experiment.run(crawler, timeout, maxConnections, true)
        } yield ExitCode.Success
      }

  }
}
