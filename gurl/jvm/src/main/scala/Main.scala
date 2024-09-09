package crawler

import shared.*

import gears.async.default.given

@main def run(timeout: Long, maxConnections: Int): Unit =
  val crawler = WebCrawler()
  Experiment.run(crawler, timeout, maxConnections)
