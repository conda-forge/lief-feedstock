#include <iostream>
#include <memory>

#include <LIEF/Abstract.hpp>
#include <LIEF/logging.hpp>

int main(int argc, char **argv) {
    LIEF::logging::set_level(LIEF::logging::LEVEL::DEBUG);

    std::cout << "LIEF Binary Introspection" << std::endl;

    const std::unique_ptr<LIEF::Binary> binary = LIEF::Parser::parse(argv[0]);

    std::cout << "== Header ==" << std::endl;
    std::cout << binary->header() << std::endl;

    std::cout << "== Imported Libraries ==" << std::endl;
    for (const auto& entry : binary->imported_libraries()) {
        std::cout << entry << std::endl;
    }

    return 0;
}
