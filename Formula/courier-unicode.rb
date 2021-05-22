class CourierUnicode < Formula
  desc "Courier Unicode Library"
  homepage "http://www.courier-mta.org/unicode/"
  url "https://sourceforge.net/projects/courier/files/courier-unicode/2.2.3/courier-unicode-2.2.3.tar.bz2"
  sha256 "08ecf5dc97529ce3aa9dcaa085860762de636ebef968bf4b6e0cdfaaf18c7aff"

  depends_on "libiconv" => :build
  depends_on "libidn" => :build
  
  def install
    ENV.deparallelize
    args = %W[
      CXXFLAGS="-std=c++11"
      --prefix=#{prefix}
      --enable-shared=true
      --enable-static=false
    ]
    system "./configure", *args
    system "make"
    system "make", "install"#, *args
  end

end
