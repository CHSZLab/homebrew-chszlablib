class Chszlablib < Formula
  desc "Python library for large-scale graph algorithms"
  homepage "https://github.com/CHSZLab/CHSZLabLib"
  url "https://github.com/CHSZLab/CHSZLabLib/archive/refs/tags/v0.5.27.tar.gz"
  sha256 "e7770579d0535d19463bc34f6d526b0abf19e84dca276305116cd2911e5b3634"
  license "MIT"

  depends_on "numpy"
  depends_on "python@3.13"

  on_macos do
    on_arm do
      resource "chszlablib-whl" do
        url "https://files.pythonhosted.org/packages/9d/00/7a986cccfdb0599d20b0979dd922cbacbd1037c3fe1c4c5b4b58f424bb8a/chszlablib-0.5.27-cp313-cp313-macosx_14_0_arm64.whl", using: :nounzip
        sha256 "670ab5f0e4eb03251e38f36d89036725d5e8c0b19b31551c78171ec532d030b1"
      end
    end
  end

  on_linux do
    on_intel do
      resource "chszlablib-whl" do
        url "https://files.pythonhosted.org/packages/0f/76/648ff6fed530e06c40da2304aa784e717970668c40633a55fa6e4d51de3f/chszlablib-0.5.27-cp313-cp313-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl", using: :nounzip
        sha256 "a58dca7eb9cc5f467db8f8cee48a1f8baa73f3e9f91892b4d08b2383bff61ef3"
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
