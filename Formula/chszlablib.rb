class Chszlablib < Formula
  desc "Python library for large-scale graph algorithms"
  homepage "https://github.com/CHSZLab/CHSZLabLib"
  url "https://github.com/CHSZLab/CHSZLabLib/archive/refs/tags/v0.6.2.tar.gz"
  sha256 "77bf318ef734eb1da37e75b549e9125f4e7db14cef2ad3f66b3132be9187ea7a"
  license "MIT"

  depends_on "numpy"
  depends_on "python@3.14"

  on_macos do
    depends_on macos: :sequoia # the macOS wheels target macOS 15.0

    on_arm do
      resource "chszlablib-whl" do
        url "https://files.pythonhosted.org/packages/b6/77/738a61b5ca8f041c8cee38636446928441e93b6dafeca6da9fc52df7a87a/chszlablib-0.6.2-cp314-cp314-macosx_15_0_arm64.whl", using: :nounzip
        sha256 "a0a189a8eabe8e31c27302465e6cd0b548b16fcccc00e64cb3fad0a809e78fca"
      end
    end
  end

  on_linux do
    on_intel do
      resource "chszlablib-whl" do
        url "https://files.pythonhosted.org/packages/cf/c3/74161f8800ff2141e75484e18fc99ac5e8c29051e61872688b4f55004bd0/chszlablib-0.6.2-cp314-cp314-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl", using: :nounzip
        sha256 "5e22d3d0fd146288bff9b71d949d2770b32ed64831ee2b14d78ec32312b4139b"
      end
    end
  end

  def python3
    which("python3.14")
  end

  def install
    site_packages = Language::Python.site_packages(python3)
    ENV.prepend_create_path "PYTHONPATH", prefix/site_packages

    resource("chszlablib-whl").stage do
      whl = Pathname.pwd.children.first
      system python3, "-m", "pip", "install",
             "--verbose", "--no-deps", "--ignore-installed",
             "--prefix=#{prefix}", whl
    end
  end

  test do
    system python3, "-c", <<~PYTHON
      import chszlablib
      G = chszlablib.Graph(5)
      G.add_edge(0, 1)
      G.add_edge(1, 2)
      G.finalize()
      assert G.num_nodes == 5
      assert G.num_edges == 2
    PYTHON
  end
end
