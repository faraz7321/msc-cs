#include <iostream>
#include <unordered_set>
#include <vector>

struct Node {
    int time_pre, time_post;
    std::vector<Node *> succs;
};

Node nodes[127];

// n is not const anymore because we need some way of getting the times out
int dfs(std::unordered_set<const Node *> &visited, Node *n, int time) {
    std::cerr << "visiting " <<(char)( n - nodes) << std::endl;
    visited.insert(n);
    n->time_pre = time;
    time++;
    for (auto m : n->succs) {
        if (visited.find(m) == visited.end()) {
            time = dfs(visited, m, time);
        }
    }
    n->time_post = time;
    time++;
    return time;
}

int main() {
    for (int i = 'a'; i <= 'z'; i++)
        nodes[i].succs = std::vector<Node*>();
    
    char root;
    std::cin >> root;
    int n;
    std::cin >> n;
    while (n--) {
        char a, b;
        std::cin >> a >> b;
        nodes[a].succs.push_back(&nodes[b]);
    }

    std::unordered_set<const Node *> visited;
    dfs(visited, &nodes[root], 1);

    for (int i = 'a'; i <= 'z'; i++) {
        std::cout << nodes[i].time_pre << " " << nodes[i].time_post << std::endl;
    }
}

