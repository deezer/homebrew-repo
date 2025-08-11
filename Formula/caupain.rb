class Caupain < Formula
  desc "Your best buddy for keeping versions catalogs up to date!"
  homepage "https://github.com/deezer/caupain"
  url "https://github.com/deezer/caupain/archive/refs/tags/v1.5.1.tar.gz"
  sha256 "07b7241ce505fd7e81e67dc893900ba0a42bbb86e32957a8c9ca7ba6f9b6b423"
  license "MIT"

  bottle do
    root_url "https://github.com/deezer/homebrew-repo/releases/download/caupain-1.5.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "3bbd8bf904eb72c83d1f39d5abe0c74f4b659a99ca5c88b7c3e168ad1ff19bfa"
    sha256 cellar: :any_skip_relocation, ventura:       "6204a94d9aa9348603d705199b798fd415f5c47d31114a4073831491e2aa6277"
  end

  depends_on "openjdk@17" => :build

  def install
    ENV["GRADLE_OPTS"] = '-Dorg.gradle.configureondemand=true \
    -Dkotlin.incremental=false \
    -Dorg.gradle.project.kotlin.incremental.multiplatform=false \
    -Dorg.gradle.project.kotlin.native.disableCompilerDaemon=true \
    -Dorg.gradle.jvmargs="-Xmx12g \
    -Dfile.encoding=UTF-8"'
    task =
      if Hardware::CPU.arm?
        ":cli:macosArm64Binaries"
      else
        ":cli:macosX64Binaries"
      end
    system "./gradlew", task, "--no-configuration-cache"
    folder =
      if Hardware::CPU.arm?
        "macosArm64"
      else
        "macosX64"
      end
    bin.install "cli/build/bin/#{folder}/releaseExecutable/caupain.kexe" => "caupain"
    bash_completion.install "cli/completions/bash-completion.sh" => "caupain"
    fish_completion.install "cli/completions/fish-completion.sh"
    zsh_completion.install "cli/completions/zsh-completion.sh" => "_caupain"
  end

  test do
    resource "testcatalog" do
      url "https://raw.githubusercontent.com/deezer/caupain/refs/heads/main/cli/tests/libs.versions.toml"
      sha256 "0438c2ab962721021790e4fea4ead214b91c5019119593a801c9da562ae374ac"
    end
    resource("testcatalog").stage do
      shell_output("#{bin}/caupain --verbose -i libs.versions.toml")
    end
  end
end
