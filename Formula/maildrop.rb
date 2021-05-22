class Maildrop < Formula
  desc "maildrop - mail delivery agent with filtering abilities"
  homepage "http://www.courier-mta.org/maildrop/index.html"
  url "https://sourceforge.net/projects/courier/files/maildrop/3.0.3/maildrop-3.0.3.tar.bz2"
  sha256 "09dc17ec706d5d2a5bde9f67b37b8f5bf9a5b6a6d9ac1ca3bd0698c3f29bfc3d"

  depends_on "pcre" => :build
  depends_on "libidn" => :build
  depends_on "libiconv" => :build
  depends_on "courier-unicode" => :build
  depends_on "gcc" => :build
  
  fails_with :clang do
    build 1205
    cause "Compilation error: clang: error: unknown argument: '-fhandle-exceptions'"
  end

  
  def install
    ENV.deparallelize
    args = %W[
        CXXFLAGS="-std=c++11"
        --mandir=#{man}
        --prefix=#{prefix}
        --with-etcdir=#{HOMEBREW_PREFIX}/etc
        --enable-syslog=1
    ]
    system "./configure", *args
    system "make","LDFLAGS=\"-liconv -L/usr/local/opt/libiconv/lib\""
    system "make","install-strip"
    system "make","install-man"
  end

end
