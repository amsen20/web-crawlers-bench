package crawler

import shared.*

@main def run(timeout: Long, maxConnections: Int): Unit =
  val crawler = WebCrawler()
  Experiment.run(crawler, timeout, maxConnections)
