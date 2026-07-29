allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

/*
 * Important:
 * Flutter plugins Pub Cache me C: drive par ho sakte hain,
 * jabki project D: drive par hai.
 *
 * Isliye sab subprojects ka build directory project ke D: drive
 * par force nahi karna hai.
 */

project(":app") {
    layout.buildDirectory.set(
        rootProject.layout.projectDirectory.dir("../build/app"),
    )
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.projectDirectory.dir("../build"))
}