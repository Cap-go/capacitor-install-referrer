#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bun run init-plugin <plugin-slug> [ClassName] [package.id] [GitHubOrg] [android-lang]

Arguments:
  plugin-slug   Required, lowercase slug without scope (example: downloader)
  ClassName     Optional, PascalCase plugin class (default from slug)
  package.id    Optional, Android/iOS reverse DNS id (default: app.capgo.<slug>)
  GitHubOrg     Optional, repository org/user (default: Cap-go)
  android-lang  Optional, Android language: java or kotlin (default: java)

Example:
  bun run init-plugin downloader CapacitorDownloader app.capgo.downloader Cap-go kotlin
USAGE
}

to_pascal_case() {
  local input="${1//[^a-zA-Z0-9]/ }"
  local out=""
  local part
  for part in $input; do
    local first
    local rest
    first="$(printf '%s' "${part:0:1}" | tr '[:lower:]' '[:upper:]')"
    rest="$(printf '%s' "${part:1}" | tr '[:upper:]' '[:lower:]')"
    out+="${first}${rest}"
  done
  printf '%s' "$out"
}

write_kotlin_build_gradle() {
  cat > "android/build.gradle" <<EOF
ext {
    junitVersion = project.hasProperty('junitVersion') ? rootProject.ext.junitVersion : '4.13.2'
    androidxAppCompatVersion = project.hasProperty('androidxAppCompatVersion') ? rootProject.ext.androidxAppCompatVersion : '1.7.1'
    androidxJunitVersion = project.hasProperty('androidxJunitVersion') ? rootProject.ext.androidxJunitVersion : '1.3.0'
    androidxEspressoCoreVersion = project.hasProperty('androidxEspressoCoreVersion') ? rootProject.ext.androidxEspressoCoreVersion : '3.7.0'
    androidxCoreKTXVersion = project.hasProperty('androidxCoreKTXVersion') ? rootProject.ext.androidxCoreKTXVersion : '1.17.0'
}

buildscript {
    ext.kotlin_version = project.hasProperty("kotlin_version") ? rootProject.ext.kotlin_version : '2.2.20'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.13.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:\$kotlin_version"
    }
}

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

android {
    namespace = "${package_id}"
    compileSdk = project.hasProperty('compileSdkVersion') ? rootProject.ext.compileSdkVersion : 36
    defaultConfig {
        minSdkVersion project.hasProperty('minSdkVersion') ? rootProject.ext.minSdkVersion : 24
        targetSdkVersion project.hasProperty('targetSdkVersion') ? rootProject.ext.targetSdkVersion : 36
        versionCode 1
        versionName "1.0"
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    lintOptions {
        abortOnError = false
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_21
        targetCompatibility JavaVersion.VERSION_21
    }
}

kotlin {
    jvmToolchain(21)
}

repositories {
    google()
    mavenCentral()
}

dependencies {
    implementation fileTree(dir: 'libs', include: ['*.jar'])
    implementation project(':capacitor-android')
    implementation "androidx.appcompat:appcompat:\$androidxAppCompatVersion"
    implementation "androidx.core:core-ktx:\$androidxCoreKTXVersion"
    testImplementation "junit:junit:\$junitVersion"
    androidTestImplementation "androidx.test.ext:junit:\$androidxJunitVersion"
    androidTestImplementation "androidx.test.espresso:espresso-core:\$androidxEspressoCoreVersion"
}
EOF
}

write_kotlin_android_sources() {
  local kotlin_dir="android/src/main/kotlin/$package_path"

  rm -rf "android/src/main/java"
  mkdir -p "$kotlin_dir"

  cat > "$kotlin_dir/${class_name}.kt" <<EOF
package ${package_id}

import com.getcapacitor.Logger

class ${class_name} {

    fun echo(value: String): String {
        Logger.info("Echo", value)

        return value
    }

    fun getPluginVersion(): String {
        return "native"
    }
}
EOF

  cat > "$kotlin_dir/${plugin_class_name}.kt" <<EOF
package ${package_id}

import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin

@CapacitorPlugin(name = "${class_name}")
class ${plugin_class_name} : Plugin() {

    private val implementation = ${class_name}()

    @PluginMethod
    fun echo(call: PluginCall) {
        val value = call.getString("value") ?: ""

        val ret = JSObject().apply {
            put("value", implementation.echo(value))
        }
        call.resolve(ret)
    }

    @PluginMethod
    fun getPluginVersion(call: PluginCall) {
        val ret = JSObject().apply {
            put("version", implementation.getPluginVersion())
        }
        call.resolve(ret)
    }
}
EOF
}

if [[ $# -lt 1 || $# -gt 5 ]]; then
  usage
  exit 1
fi

slug="$1"
class_name="${2:-$(to_pascal_case "$slug")}"
package_id="${3:-app.capgo.${slug//-/_}}"
github_org="${4:-Cap-go}"
android_lang="$(printf '%s' "${5:-java}" | tr '[:upper:]' '[:lower:]')"

if [[ ! "$slug" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "Invalid plugin slug: $slug"
  echo "Use lowercase letters, numbers, and dashes only."
  exit 1
fi

if [[ ! "$class_name" =~ ^[A-Za-z][A-Za-z0-9]*$ ]]; then
  echo "Invalid class name: $class_name"
  echo "Use PascalCase letters/numbers only."
  exit 1
fi

if [[ ! "$package_id" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
  echo "Invalid package id: $package_id"
  echo "Expected reverse DNS format, for example: app.capgo.downloader"
  exit 1
fi

if [[ ! "$android_lang" =~ ^(java|kotlin)$ ]]; then
  echo "Invalid android language: $android_lang"
  echo 'Use "java" or "kotlin".'
  exit 1
fi

repo_name="capacitor-$slug"
package_name="@capgo/$repo_name"
native_name="CapgoCapacitor${class_name}"
plugin_class_name="${class_name}Plugin"
package_path="${package_id//./\/}"
first_char="${class_name:0:1}"
first_char_lower="$(printf '%s' "$first_char" | tr '[:upper:]' '[:lower:]')"
rollup_name="capacitor${first_char_lower}${class_name:1}"
repo_url="https://github.com/${github_org}/${repo_name}"

file_list="$(mktemp -t capgo-plugin-template-files)"
trap 'rm -f "$file_list"' EXIT

find . -type f \
  ! -path './.git/*' \
  ! -path './node_modules/*' \
  ! -path './dist/*' \
  ! -path './android/.gradle/*' \
  ! -path './android/build/*' \
  ! -path './example-app/node_modules/*' \
  ! -path './example-app/dist/*' \
  > "$file_list"

replace_all() {
  local search="$1"
  local replace="$2"
  if [[ "$search" == "$replace" ]]; then
    return
  fi

  local file
  while IFS= read -r file; do
    SEARCH="$search" REPLACE="$replace" perl -0pi -e 's/\Q$ENV{SEARCH}\E/$ENV{REPLACE}/g' "$file"
  done < "$file_list"
}

replace_all '@capgo/capacitor-plugin-template' "$package_name"
replace_all 'https://github.com/Cap-go/capacitor-plugin-template' "$repo_url"
replace_all 'capacitor-plugin-template' "$repo_name"
replace_all 'CapgoCapacitorPluginTemplate' "$native_name"
replace_all 'PluginTemplatePlugin' "$plugin_class_name"
replace_all 'PluginTemplate' "$class_name"
replace_all 'app.capgo.plugintemplate' "$package_id"
replace_all 'app/capgo/plugintemplate' "$package_path"
replace_all 'capacitorPluginTemplate' "$rollup_name"

if [[ -f "CapgoCapacitorPluginTemplate.podspec" ]]; then
  mv "CapgoCapacitorPluginTemplate.podspec" "${native_name}.podspec"
fi

if [[ -d "ios/Sources/PluginTemplatePlugin" ]]; then
  mv "ios/Sources/PluginTemplatePlugin" "ios/Sources/${plugin_class_name}"
fi

if [[ -d "ios/Tests/PluginTemplatePluginTests" ]]; then
  mv "ios/Tests/PluginTemplatePluginTests" "ios/Tests/${plugin_class_name}Tests"
fi

if [[ -f "ios/Sources/${plugin_class_name}/PluginTemplate.swift" ]]; then
  mv "ios/Sources/${plugin_class_name}/PluginTemplate.swift" "ios/Sources/${plugin_class_name}/${class_name}.swift"
fi

if [[ -f "ios/Sources/${plugin_class_name}/PluginTemplatePlugin.swift" ]]; then
  mv "ios/Sources/${plugin_class_name}/PluginTemplatePlugin.swift" "ios/Sources/${plugin_class_name}/${plugin_class_name}.swift"
fi

if [[ -f "ios/Tests/${plugin_class_name}Tests/PluginTemplateTests.swift" ]]; then
  mv "ios/Tests/${plugin_class_name}Tests/PluginTemplateTests.swift" "ios/Tests/${plugin_class_name}Tests/${class_name}Tests.swift"
fi

if [[ "$android_lang" == "java" ]]; then
  if [[ -d "android/src/main/java/app/capgo/plugintemplate" ]]; then
    mkdir -p "android/src/main/java/$(dirname "$package_path")"
    mv "android/src/main/java/app/capgo/plugintemplate" "android/src/main/java/$package_path"
  fi

  if [[ -f "android/src/main/java/$package_path/PluginTemplate.java" ]]; then
    mv "android/src/main/java/$package_path/PluginTemplate.java" "android/src/main/java/$package_path/${class_name}.java"
  fi

  if [[ -f "android/src/main/java/$package_path/PluginTemplatePlugin.java" ]]; then
    mv "android/src/main/java/$package_path/PluginTemplatePlugin.java" "android/src/main/java/$package_path/${plugin_class_name}.java"
  fi
else
  write_kotlin_build_gradle
  write_kotlin_android_sources
fi

echo "Template initialized."
echo "Package: $package_name"
echo "Class: $class_name"
echo "Package ID: $package_id"
echo "Android language: $android_lang"
echo "Repo URL: $repo_url"
