class Caupain < Formula
  desc "Your best buddy for keeping versions catalogs up to date!"
  homepage "https://github.com/deezer/caupain"
  url "https://github.com/deezer/caupain/archive/refs/tags/v1.2.1.tar.gz"
  sha256 "ec43e016b73fe0e4a198d3d23d420b3669db1b0f0de6d2f30e4d13b1fdd420ba"
  license "MIT"

  bottle do
    root_url "https://github.com/deezer/homebrew-repo/releases/download/caupain-1.2.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "12906b1c23a37ab788bff6776aa146935d34c1fc10955462b5c8fc01870384d6"
    sha256 cellar: :any_skip_relocation, ventura:       "d5380c20332c17f5502f0c72c26cc0c0fa89757b3f52d4cd2d35a836687157ce"
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
