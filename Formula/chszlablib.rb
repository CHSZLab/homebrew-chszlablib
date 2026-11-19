class Chszlablib < Formula
  desc "Python library for large-scale graph algorithms"
  homepage "https://github.com/CHSZLab/CHSZLabLib"
  url "https://github.com/CHSZLab/CHSZLabLib/archive/refs/tags/v0.6.1.tar.gz"
  sha256 "29a432c382d4a51c238b60c26add075e02b242367821ed1c53d2920eb80bb96d"
  license "MIT"

  depends_on "numpy"
  depends_on "python@3.13"

  on_macos do
    depends_on macos: :sequoia # the macOS wheels target macOS 15.0

    on_arm do
      resource "chszlablib-whl" do
        url "https://files.pythonhosted.org/packages/ef/c7/61d33f2d1c26a944bf63947fa8319c5f8da5d8fab36c05999dcccfaba3be/chszlablib-0.6.1-cp313-cp313-macosx_15_0_arm64.whl", using: :nounzip
        sha256 "ba4699a94bab7d5d3dead2fa7475d771d452a4fe55158905dad23a100438ea18"
      end
    end
  end

  on_linux do
    on_intel do
      resource "chszlablib-whl" do
        url "https://files.pythonhosted.org/packages/4c/d3/9e1f61c03136d6ea782ab946e95641bf0f92da99fda38d78f6c1a7c2530a/chszlablib-0.6.1-cp313-cp313-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl", using: :nounzip
        sha256 "c4b2b0d61d785756bf7671813997f4e42e7a9a502dcd35ac8602846ffa1d5952"
      end
    end
  end

  def python3
    which("python3.13")
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
