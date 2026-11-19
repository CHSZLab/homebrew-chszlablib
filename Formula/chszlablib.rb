class Chszlablib < Formula
  desc "Python library for large-scale graph algorithms"
  homepage "https://github.com/CHSZLab/CHSZLabLib"
  url "https://github.com/CHSZLab/CHSZLabLib/archive/refs/tags/v0.6.1.tar.gz"
  sha256 "29a432c382d4a51c238b60c26add075e02b242367821ed1c53d2920eb80bb96d"
  license "MIT"

  depends_on "numpy"
  depends_on "python@3.14"

  on_macos do
    depends_on macos: :sequoia # the macOS wheels target macOS 15.0

    on_arm do
      resource "chszlablib-whl" do
        url "https://files.pythonhosted.org/packages/a1/72/da7ae78f1c3c8f245c3a97f5738306379c2d7c807e7c9a0632b60ccfd54b/chszlablib-0.6.1-cp314-cp314-macosx_15_0_arm64.whl", using: :nounzip
        sha256 "4693fb05035a7336a3ee4aadcf70dc83b7280675512f98ffc57da1bfccef9eae"
      end
    end
  end

  on_linux do
    on_intel do
      resource "chszlablib-whl" do
        url "https://files.pythonhosted.org/packages/fd/68/171aaffc4e7c94a9057c671c12896bc395e6f8d3c7bd3953f4024601253f/chszlablib-0.6.1-cp314-cp314-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl", using: :nounzip
        sha256 "9b46fe9e4a7bc93fad5d731d086af3ed846c2c936965e6beccf13b63dc20ea2a"
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
