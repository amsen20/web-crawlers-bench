package crawler

import shared.Experiment
import cats.effect._

object Main extends IOApp {
  def run(args: List[String]): IO[ExitCode] = {
    Experiment.run().as(ExitCode.Success)
  }
}
