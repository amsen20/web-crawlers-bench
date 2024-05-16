import sbtcrossproject.CrossPlugin.autoImport.{crossProject, CrossType}
import scalanative.build._

val scala3Version = "3.3.3"

val isDebug = false

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

lazy val shared = crossProject(JVMPlatform, NativePlatform)
  .crossType(CrossType.Full)
  .in(file("shared"))
  .settings(
    scalaVersion := scala3Version,
    libraryDependencies ++= Seq(
      "ch.epfl.lamp" %% "gears" % "0.2.0"
    )
  )

lazy val sharedJVM = shared.jvm
lazy val sharedNative = shared.native

lazy val jvm = project
  .in(file("jvm"))
  .dependsOn(sharedJVM)
  .settings(
    name := "web-crawler-gears-jvm",
    version := "0.1.0-SNAPSHOT",
    scalaVersion := scala3Version,
    libraryDependencies ++= Seq(
      "org.scalameta" %% "munit" % "0.7.29" % Test,
      "ch.epfl.lamp" %% "gears" % "0.2.0",
      "com.lihaoyi" %% "requests" % "0.8.2"
    )
  )

lazy val native = project
  .in(file("native"))
  .enablePlugins(ScalaNativePlugin)
  .dependsOn(sharedNative)
  .settings(
    name := "web-crawler-gears-native",
    version := "0.1.0-SNAPSHOT",
    scalaVersion := scala3Version,
    libraryDependencies ++= Seq(
      "ca.uwaterloo.plg" %%% "gurl" % "0.1-9f6f0d9-20240516T171015Z-SNAPSHOT"
      // "org.scalameta" %% "munit" % "0.7.29" % Test,
      // "ch.epfl.lamp" %% "gears" % "0.2.0",
      // "com.lihaoyi" %% "requests" % "0.8.2",
    )
  )
