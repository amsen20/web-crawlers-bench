package crawler

import ca.uwaterloo.plg.curl.unsafe.CurlMultiRuntime

import shared.*

@main def run(timeout: Long, maxConnections: Int): Unit =
  CurlMultiRuntime:
    val crawler = WebCrawler()
    Experiment.run(crawler, timeout, maxConnections)
  