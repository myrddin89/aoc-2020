#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <ranges>

int main(int argc, const char** argv)
{
    using std::views::iota, std::ranges::for_each, std::getline;

    int slopes[5][2] = { {1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2} };
    int trees[5] = { 0 };
    int prod = 1;

    for (auto i : iota(0))
    {
        if (!std::cin) break;
        std::string l;
        getline(std::cin, l);
        if (l.empty()) break;
        for_each(iota(0, 5), [&](auto s) {
            auto [r, d] = slopes[s];
            if (i % d != 0) return;
            if (l[((i / d) * r) % l.length()] == '#') trees[s] += 1;
        });
    };

    for_each(trees, [&](auto n) { prod *= n; });

    std::cout << prod << std::endl;

    return 0;
}

// int main(int argc, const char** argv)
// {
//     using std::views::iota, std::ranges::for_each, std::getline;

//     int slopes[5][2] = { {1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2} };
//     int trees[5] = { 0 };
//     int prod = 1;

//     for (auto i : iota(0))
//     {
//         if (!std::cin) break;
//         std::string l;
//         getline(std::cin, l);
//         if (l.empty()) break;
//         for_each(iota(0, 5), [&](auto s) {
//             auto [r, d] = slopes[s];
//             if (i % d != 0) return;
//             if (l[((i / d) * r) % l.length()] == '#') trees[s] += 1;
//         });
//     };

//     for_each(trees, [&](auto n) { prod *= n; });

//     std::cout << prod << std::endl;

//     return 0;
// }
