import sbtcrossproject.CrossPlugin.autoImport.{crossProject, CrossType}
import scalanative.build._

ThisBuild / scalaVersion := "3.3.3"
ThisBuild / scalacOptions += "-deprecation"

val purlVersion = "0.2-a688e8b-20240909T192735Z-SNAPSHOT"

val isDebug = false

lazy val root = project
  .in(file("."))
  .enablePlugins(ScalaNativePlugin)
  .settings(
    name := "crawler",
    version := "0.1.0-SNAPSHOT",
    libraryDependencies ++= Seq(
      "ca.uwaterloo.plg" %%% "purl" % purlVersion
    )
  )

ThisBuild / nativeConfig ~= { c =>
  val platformOptions = c
    .withMultithreading(true)
    .withLTO(LTO.none)
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
  else
    platformOptions
      .withMode(Mode.releaseFull)
      .withOptimize(true)
}
