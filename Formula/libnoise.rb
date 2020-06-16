class Libnoise < Formula
  desc "Fork of libnoise which changes the build system from static Makefiles to cmake"
  homepage "https://github.com/qknight/libnoise"
  head "https://github.com/qknight/libnoise.git", :using => :git

  depends_on "cmake" => :build
  
  def install
    ENV.deparallelize
    system "cmake", "-DCMAKE_INSTALL_PREFIX=#{prefix}","."
    system "make"
    system "make","install"
    system "cp","-r","cmake","#{prefix}/lib"
  end


  test do
    (testpath/"CMakeLists.txt").write <<~EOS
      project(FOO)
      cmake_minimum_required(VERSION 2.8)

      find_package(LibNoise)

      if (LIBNOISE_FOUND)
        include(${LIBNOISE_INCLUDE_DIR})
      else (LIBNOISE_FOUND)
        message(FATAL_ERROR "Please install LibNoise")
      endif (LIBNOISE_FOUND)
 
      file(GLOB FOO_SOURCE ${FOO_SOURCE_DIR}/*.cpp)
      file(GLOB FOO_INCLUDE ${FOO_SOURCE_DIR}/*.h)

      add_executable (foo ${FOO_SOURCE})
      target_link_libraries(foo ${LIBNOISE_LIBRARIES})
    EOS
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include <noise/noise.h>

      using namespace noise;

      int main (int argc, char** argv)
      {
        module::Perlin myModule;
        double value = myModule.GetValue (1.25, 0.75, 0.50);
        std::cout << "OK" << std::endl;
        return 0;
      }
    EOS
    system "cmake", "."
    system "make"
    assert_equal "OK", shell_output("./foo").strip
  end
end
