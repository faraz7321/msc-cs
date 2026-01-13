template<int N>
struct Loop {
    using next = Loop<N + 1>;     // forces another instantiation
    using type = typename next::type;
};

int main() {
    typename Loop<0>::type x;     // triggers infinite instantiation
}