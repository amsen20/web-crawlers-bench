import sbtcrossproject.CrossPlugin.autoImport.{crossProject, CrossType}
import scalanative.build._

ThisBuild / scalaVersion := "3.3.3"

val gearsVersion = "0.2.0"
val gurlVersion = "0.1-beb506e-SNAPSHOT"

val isDebug = false

lazy val root = crossProject(JVMPlatform, NativePlatform)
  .crossType(CrossType.Full)
  .in(file("."))
  .settings(
    name := "web-crawler-gears",
    version := "0.1.0-SNAPSHOT",
    libraryDependencies ++= Seq(
      "org.scalameta" %%% "munit" % "1.0.0-RC1" % Test,
      "ch.epfl.lamp" %%% "gears" % gearsVersion
    ),
    testFrameworks += new TestFramework("munit.Framework")
  )
  .jvmSettings(
    libraryDependencies += "com.lihaoyi" %% "requests" % "0.8.2"
  )
  .nativeSettings(
    libraryDependencies += "ca.uwaterloo.plg" %%% "gurl" % gurlVersion
  )

ThisBuild / nativeConfig ~= { c =>
  val platformOptions = c
    .withMultithreading(true)
    .withLTO(LTO.none)
    .withMode(Mode.debug)
    .withGC(GC.immix)
  if (isDebug)
    platformOptions
      .withSourceLevelDebuggingConfig(
        _.enableAll
      ) // enable generation of debug informations
      .withOptimize(false) // disable Scala Native optimizer
      .withMode(
        scalanative.build.Mode.debug
      ) // compile using LLVM without optimizations
      .withCompileOptions(Seq("-DSCALANATIVE_DELIMCC_DEBUG"))
  else platformOptions
}
