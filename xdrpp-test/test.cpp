#include <iostream>
#include <fstream>
#include <vector>
#include <iterator>
#include <string>
#include <sstream>
#include <xdrpp/types.h>
#include <xdrpp/marshal.h>
#include <xdrpp/printer.h>
#include "Stellar.hh"

using xdr::operator<<;

// copied from https://stackoverflow.com/a/21802936
std::vector<uint8_t> readFile(const char* filename)
{
  // open the file:
  std::ifstream file(filename, std::ios::binary);

  // Stop eating new lines in binary mode!!!
  file.unsetf(std::ios::skipws);

  // get its size:
  std::streampos fileSize;

  file.seekg(0, std::ios::end);
  fileSize = file.tellg();
  file.seekg(0, std::ios::beg);

  // reserve capacity
  std::vector<uint8_t> vec;
  vec.reserve(fileSize);

  // read the data:
  vec.insert(vec.begin(),
      std::istream_iterator<uint8_t>(file),
      std::istream_iterator<uint8_t>());

  return vec;
}


int main (int argc, char** argv) {
  std::string inFile = "";
  if( argc == 2 ) {
    inFile = argv[1];
  }
  else {
    std::cout << "Usage: ./cppfile datafile.bin\n";
    return 1;
  }

  TestCase tc;
  std::vector<uint8_t> data = readFile(inFile.c_str());

  xdr::xdr_get g(&data.front(), &data.back() + 1);
  xdr::xdr_argpack_archive(g, tc);
  g.done();

  std::cout << tc << std::endl;
}
