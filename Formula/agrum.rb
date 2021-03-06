class Agrum < Formula
  desc "C++ library for graphical models"
  homepage "https://agrum.gitlab.io/pages/agrum.html"
  url "https://gitlab.com/agrumery/aGrUM.git", :tag => "0.20.1", :revision => "c816ce8e79e03596e874b42f32ee381a8c351f25"
  # Previous 0.18.1 OSX working version in case you need it
  #head "https://gitlab.com/agrumery/aGrUM.git", :branch => "feature/odbc4mac", :revision => "65e744149497a8cc5b69620d3aa55fd29d7e17e1"
  
  option "with-openmp", "Build the formula with OpenMP support"
  
  depends_on "bash" => :build
  depends_on "cmake" => [:build, :test]
  depends_on "coreutils" => :build
  depends_on "mariadb-connector-odbc" => :build
  if build.with? "openmp"
      depends_on "libomp" => [:build, :test]
  end
  depends_on "python@3.8" => :build

  def install
    inreplace "src/cmake/Nanodbc.agrum.cmake",
              "option(USE_NANODBC \"Build with nanodbc support\" ON)",
              "option(USE_NANODBC \"Build with nanodbc support\" OFF)"
    if build.without? "openmp"
        inreplace "CMakeLists.txt",
                  "option(USE_OPENMP \"use openmp\" ON)",
                  "option(USE_OPENMP \"use openmp\" OFF)"
    end
    ENV.deparallelize
    system "python", "act", "install", "release", "aGrUM", "--static", "-d", prefix
  end

  head do
    url "https://gitlab.com/agrumery/aGrUM.git"
  end

  test do
    # `
    (testpath/"CMakeLists.txt").write <<~EOS
      project(FOO)
      cmake_minimum_required(VERSION 2.8)
      set (CMAKE_CXX_STANDARD 14)

      if build.with? "openmp"
      find_package(OpenMP)
      if (OPENMP_FOUND)
        set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
        set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
        set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
      endif()
      end

      find_package(aGrUM)

      if (aGrUM_FOUND)
        include(${AGRUM_USE_FILE})
      else (aGrUM_FOUND)
        message(FATAL_ERROR "Please install aGrUM")
      endif (aGrUM_FOUND)
 
      file(GLOB FOO_SOURCE ${FOO_SOURCE_DIR}/*.cpp)
      file(GLOB FOO_INCLUDE ${FOO_SOURCE_DIR}/*.h)

      add_executable (foo ${FOO_SOURCE})
      target_link_libraries(foo agrum)
    EOS
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>

      #include <agrum/tools/core/hashTable.h>

      int main() {
        gum::HashTable<std::string,int> h;

        h.insert("Hello",1);
        h.insert("World",2);

        std::cout<<h<<std::endl;
      }
    EOS
    system "cmake", "."
    system "make"
    assert_equal "{World=>2 , Hello=>1}", shell_output("./foo").strip
    if build.with? "all_tests"
        system  "python", "act", "test", "release", "agrum", "-t", "all"
    end
  end
end
