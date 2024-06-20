import sbtcrossproject.CrossPlugin.autoImport.{crossProject, CrossType}
import scalanative.build._

ThisBuild / scalaVersion := "3.3.3"

val catsVersion = "3.5.4"

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
  )
  .nativeSettings(
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
