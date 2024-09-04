package crawler

import shared.*

import purl.multi._
import purl.global._
import gears.async.native.SuspendExecutorWithSleep
import gears.async._
import pollerBear.runtime._

import scala.concurrent.JavaConversions._
import scala.concurrent.ExecutionContext
import java.util.concurrent.ForkJoinPool

given ExecutionContext = ExecutionContext.global

@main def run(threadsNum: Int, timeout: Long, maxConnections: Int): Unit =
  CurlGlobal:
    withActivePoller:
      CurlMultiRuntime:
        val crawler = WebCrawler()

        /** Manually setting the default support to ForkJoinSupport, to enabling
          * changing parallelism level of the ForkJoinPool based on number of
          * available processors.
          */
        class ForkJoinSupport
            extends SuspendExecutorWithSleep(new ForkJoinPool(threadsNum))
        object DefaultSupport extends ForkJoinSupport
        given AsyncSupport = DefaultSupport
        given DefaultSupport.Scheduler = DefaultSupport
        given AsyncOperations = DefaultSupport

        Experiment.run(crawler, timeout, maxConnections)
