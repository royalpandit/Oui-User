allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    project.layout.buildDirectory.value(newBuildDir.dir(project.name))
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

//buildscript {
//    ext.kotlin_version = '1.9.25'
//    repositories {
//        google()
//        mavenCentral()
//    }
//
//    dependencies {
//        classpath 'com.android.tools.build:gradle:7.2.0'
//        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
//    }
//}
//
//allprojects {
//    repositories {
//        google()
//        mavenCentral()
//    }
//}
//
//rootProject.buildDir = '../build'
//subprojects {
//    project.buildDir = "${rootProject.buildDir}/${project.name}"
//}
//subprojects {
//    project.evaluationDependsOn(':app')
//}
//
//tasks.register("clean", Delete) {
//    delete rootProject.buildDir
//}
