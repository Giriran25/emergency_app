allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = rootProject.file("../build")
rootProject.buildDir = newBuildDir

subprojects {
    buildDir = File(rootProject.buildDir, project.name)
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
