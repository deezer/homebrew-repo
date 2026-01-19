class Caupain < Formula
  desc "Your best buddy for keeping versions catalogs up to date!"
  homepage "https://github.com/deezer/caupain"
  url "https://github.com/deezer/caupain/archive/refs/tags/v1.8.1.tar.gz"
  sha256 "d1f7b522bb2b2959e556f8c9023552e4f227c62838fb2da924a7639e56c044ee"
  license "MIT"

  bottle do
    root_url "https://github.com/deezer/homebrew-repo/releases/download/caupain-1.8.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "192754d7c88e041954678a24c9b4367c27e06d7d0fb4a12f12f9e4abfbc40eed"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "82db478cdec01873a1da0615a8ac9bbe6bd64722cc729cf7e039d3156fabce68"
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
