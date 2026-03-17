class Caupain < Formula
  desc "Your best buddy for keeping versions catalogs up to date!"
  homepage "https://github.com/deezer/caupain"
  url "https://github.com/deezer/caupain/archive/refs/tags/v1.9.1.tar.gz"
  sha256 "83cb1f587a4bea81bc9d4b0a4d8f75e9a48a7a6c68ac713c1612d93eb65d60b8"
  license "MIT"

  bottle do
    root_url "https://github.com/deezer/homebrew-repo/releases/download/caupain-1.9.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "59362db55470a6bcad06dbee1cfc4b3f4b2562852dc17778663570c73aee7f16"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0dccd6f244704959a7c5cade654afe3672ce45406c909defafd1b21e3cfd0b44"
  end

  depends_on "openjdk" => :build

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
