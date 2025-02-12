class ArmNoneEabiGdb < Formula
  desc "GNU debugger for arm-none-eabi cross development"
  homepage "https://www.gnu.org/software/gdb/"
  url "https://ftp.gnu.org/gnu/gdb/gdb-16.2.tar.xz"
  mirror "https://ftpmirror.gnu.org/gdb/gdb-16.2.tar.xz"
  sha256 "4002cb7f23f45c37c790536a13a720942ce4be0402d929c9085e92f10d480119"
  license "GPL-3.0-or-later"
  head "https://sourceware.org/git/binutils-gdb.git", branch: "master"

  livecheck do
    formula "gdb"
  end

  bottle do
    sha256 arm64_sequoia: "f65b635fd9e25b640a6eb95eccbfae48107a24ee3c0e79c5244540a70af23f8c"
    sha256 arm64_sonoma:  "3bef540704b5fe721617e765aafe78b038d59bba4f208221371721fcdb33b62d"
    sha256 arm64_ventura: "9e1a328344bdeb83168921e6c659dff60176894dc4b35f05b1e91e66a1e8e326"
    sha256 sonoma:        "afc6b9e86828e50d6a06a88a78a053f0922c78712fc8bf453e67eba3403d572f"
    sha256 ventura:       "e9d346bdd318547661c7f98843877ea5d282f15af424af4234553c73170c6d66"
    sha256 x86_64_linux:  "7df0ac86aa70a50f11ec3f558b3ecee4c06129bbbb086a1bd4fb106a16eb3b2e"
  end

  depends_on "arm-none-eabi-gcc" => :test
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "python@3.13"
  depends_on "xz" # required for lzma support

  uses_from_macos "expat"
  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  on_system :linux, macos: :ventura_or_newer do
    depends_on "texinfo" => :build
  end

  def install
    target = "arm-none-eabi"
    args = %W[
      --target=#{target}
      --datarootdir=#{share}/#{target}
      --includedir=#{include}/#{target}
      --infodir=#{info}/#{target}
      --mandir=#{man}
      --with-lzma
      --with-python=#{Formula["python@3.13"].opt_bin}/python3.13
      --with-system-zlib
      --disable-binutils
    ]

    mkdir "build" do
      system "../configure", *args, *std_configure_args
      ENV.deparallelize # Error: common/version.c-stamp.tmp: No such file or directory
      system "make"

      # Don't install bfd or opcodes, as they are provided by binutils
      system "make", "install-gdb"
    end
  end

  test do
    (testpath/"test.c").write "void _start(void) {}"
    system "#{Formula["arm-none-eabi-gcc"].bin}/arm-none-eabi-gcc", "-g", "-nostdlib", "test.c"
    assert_match "Symbol \"_start\" is a function at address 0x",
          shell_output("#{bin}/arm-none-eabi-gdb -batch -ex 'info address _start' a.out")
  end
end
