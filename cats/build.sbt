import sbtcrossproject.CrossPlugin.autoImport.{crossProject, CrossType}
import scalanative.build._

ThisBuild / scalaVersion := "3.3.3"

val catsVersion = "3.5.4"
val http4sVersion = "0.23.27"
val htt4psCurlVersion = "0.2.0"

val isDebug = false

lazy val root = crossProject(JVMPlatform, NativePlatform)
  .crossType(CrossType.Full)
  .in(file("."))
  .settings(
    name := "web-crawler-cats-effect",
    version := "0.1.0-SNAPSHOT",
    libraryDependencies ++= Seq(
      "org.typelevel" %%% "cats-effect" % catsVersion
    )
  )
  .jvmSettings(
    fork := true,
    libraryDependencies ++= Seq(
      "org.http4s" %%% "http4s-ember-client" % http4sVersion
    )
  )
  .nativeSettings(
    libraryDependencies ++= Seq(
      "org.http4s" %%% "http4s-curl" % htt4psCurlVersion
    )
  )

ThisBuild / nativeConfig ~= { c =>
  val platformOptions = c
    // .withMultithreading(true)
    .withLTO(LTO.none)
    .withGC(GC.immix)
  if (isDebug)
    platformOptions
      .withMode(Mode.debug)
      .withOptimize(false)
  else
    platformOptions
      .withMode(Mode.releaseFull)
      .withOptimize(true)
}
