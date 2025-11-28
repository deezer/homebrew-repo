class Caupain < Formula
  desc "Your best buddy for keeping versions catalogs up to date!"
  homepage "https://github.com/deezer/caupain"
  url "https://github.com/deezer/caupain/archive/refs/tags/v1.7.0.tar.gz"
  sha256 "699f0daee34de2832a5d279451d99a12ca33b8c8c3977244f7259f0ad14fca53"
  license "MIT"

  bottle do
    root_url "https://github.com/deezer/homebrew-repo/releases/download/caupain-1.7.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "de8f4288c7e51a3884e248be2df02218351de756072886986c4537e246598a2b"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ab7c4ca15d2525f8dc1121f11b7952610b664f3c2ca9abfb98a56f7d56aa2c24"
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
